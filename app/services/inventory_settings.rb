# frozen_string_literal: true

# Handles the interaction with the inventory Settings
module InventorySettings
  class << self
    include Deterministic::Prelude

    ALLOWED_UPDATE_ARGUMENTS = %i[low_quantity high_quantity].freeze

    def update_settings(inventory, params)
      in_sequence do
        get(:sanitized_params) { sanitaze_params(params) }
        get(:updated_inventory) { update_inventory_settings(inventory, sanitized_params) }
        and_yield { format_response(updated_inventory) }
      end
    end

    def sanitaze_params(params)
      sanitized_params = params.symbolize_keys.reject { |k, v| !ALLOWED_UPDATE_ARGUMENTS.include?(k) || v.nil? }

      sanitized_params.blank? ? Failure(message: "Quantity can't be null") : Success(sanitized_params)
    end

    def update_inventory_settings(inventory, params)
      inventory.inventory_setting.update(params)

      Success(inventory)
    end

    def format_response(inventory)
      Success({
                id: inventory.store.id,
                name: inventory.store.name,
                product: {
                  id: inventory.product.id,
                  model: inventory.product.model,
                  inventory: inventory.quantity,
                  inventory_settings: {
                    high_quantity: inventory.inventory_setting.high_quantity,
                    low_quantity: inventory.inventory_setting.low_quantity
                  }
                }
              })
    end
  end
end
