# frozen_string_literal: true

# Receives inventory data to be processed
class InventoryUpdateJob < ApplicationJob
  queue_as :default

  def perform(params)
    Inventories.update_inventory(params)
  end
end
