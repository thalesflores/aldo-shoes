# frozen_string_literal: true

# Handles the interaction with the inventory flow
module Inventories
  class << self
    include Deterministic::Prelude

    REQUIRED_ARGUMENTS = %i[store model inventory].freeze

    def update_inventory(params)
      in_sequence do
        get(:sanitized_params) { sanitaze_params(params) }
        get(:store) { upsert_store(sanitized_params[:store_name]) }
        get(:product) { upsert_product(sanitized_params[:model_name]) }
        get(:product_inventory) { upsert_inventory(store.id, product.id) }
        get(:updated_inventory) { update_inventory_quantity(product_inventory, sanitized_params[:inventory_quantity]) }
        and_yield { format_response(updated_inventory, store, product) }
      end
    end

    def transfer(from_store_inventory:, to_store_id:, product_id:, quantity:)
      in_sequence do
        get(:to_store_inventory) { store_inventory_by_id(to_store_id, product_id) }
        get(:inventories) { execute_transfer(from_store_inventory, to_store_inventory, quantity) }
        and_yield { transfer_response(inventories) }
      end
    end

    def transfer_suggestions(store:)
      in_sequence do
        get(:receive_transfer_suggestions) { list_receive_transfer_suggestions(store.id) }
        get(:send_transfer_suggestions) { list_send_transfer_suggestions(store.id) }
        and_yield { transfer_suggestions_response(store, receive_transfer_suggestions, send_transfer_suggestions) }
      end
    end

    def list_receive_transfer_suggestions(store_id)
      Success(Inventory.receive_transfer_suggestions_by_store_id(store_id))
    end

    def list_send_transfer_suggestions(store_id)
      Success(Inventory.send_transfer_suggestions_by_store_id(store_id))
    end

    def store_inventory_by_id(from_store_id, product_id)
      inventory = Inventory.find_by_store_and_product(from_store_id, product_id)

      inventory ? Success(inventory) : Failure(message: 'Destination store not found', code: :not_found)
    end

    def execute_transfer(from_store_inventory, to_store_inventory, quantity)
      ActiveRecord::Base.transaction do
        from_store_inventory.quantity -= quantity

        raise Inventory::InsufficientQuantity if from_store_inventory.quantity.negative?

        to_store_inventory.quantity += quantity

        from_store_inventory.save!
        to_store_inventory.save!
        Success(to_store_inventory:, from_store_inventory:)

      rescue Inventory::InsufficientQuantity
        Failure(message: "You can't transfer more units than you have in the inventory")
      end
    end

    def transfer_response(inventories)
      Success({
                origin_store: bulild_transfer_response(inventories[:from_store_inventory]),
                destination_store: bulild_transfer_response(inventories[:to_store_inventory])
              })
    end

    def bulild_transfer_response(inventory)
      {
        id: inventory.store.id,
        name: inventory.store.name,
        product: {
          id: inventory.product.id,
          model: inventory.product.model,
          inventory: inventory.quantity
        }
      }
    end

    def transfer_suggestions_response(store, receive_transfer_suggestions, send_transfer_suggestions)
      Success({
                id: store.id,
                name: store.name,
                inventory_transfers_suggestions: {
                  send_transfers: send_transfer_suggestions.map do |suggestion|
                                    format_suggestion_response(suggestion.symbolize_keys)
                                  end,
                  receive_transfers: receive_transfer_suggestions.map do |suggestion|
                                       format_suggestion_response(suggestion.symbolize_keys)
                                     end
                }
              })
    end

    def format_suggestion_response(suggestion)
      {
        store: { id: suggestion[:store_id], name: suggestion[:store_name] },
        product: {
          id: suggestion[:product_id],
          model: suggestion[:product_model],
          quantity: suggestion[:transfer_suggestion]
        }
      }
    end

    def sanitaze_params(params)
      struct_params = OpenStruct.new(params)

      invalid_arguments = REQUIRED_ARGUMENTS.filter { |argument| struct_params[argument].nil? }

      return Failure("Missing required arguments: #{invalid_arguments}") unless invalid_arguments.blank?

      Success({ store_name: struct_params[:store], model_name: struct_params[:model],
                inventory_quantity: struct_params[:inventory] })
    end

    def upsert_store(store)
      Success(Store.find_or_create_by(name: store))
    end

    def upsert_product(model)
      Success(Product.find_or_create_by(model:))
    end

    def upsert_inventory(store_id, product_id)
      Success(Inventory.find_or_create_by(store_id:, product_id:))
    end

    def update_inventory_quantity(inventory, quantity)
      inventory.update(quantity:)
      inventory.valid? ? Success(inventory) : Failure(inventory.errors)
    end

    def format_response(inventory, store, product)
      Success(inventory:, store:, product:)
    end
  end
end
