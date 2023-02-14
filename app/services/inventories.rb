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
