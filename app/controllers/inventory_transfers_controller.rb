class InventoryTransfersController < ApplicationController
  include Deterministic::Prelude

  before_action :find_store_inventory, only: [:create]

  def create
    transfer = Inventories.transfer(
      from_store_inventory: @from_store_inventory,
      to_store_id: transfer_params[:destination_store],
      product_id: transfer_params[:product_id],
      quantity: Integer(transfer_params[:quantity])
    )

    transfer.match do
      Success() { |s| render json: { transfer: s }, status: 201 }
      Failure() { |f| render json: { message: f[:message] }, status: f[:code] || 422 }
    end
  end

  private

  def find_store_inventory
    @from_store_inventory = Inventory.find_by_store_and_product(params[:id], transfer_params[:product_id])

    raise ActiveRecord::RecordNotFound unless @from_store_inventory
  end

  def transfer_params
    params.permit(:product_id, :quantity, :destination_store)
  end

  def build_response(store)
    {
      id: store.id,
      name: store.name,
      product: store.inventories.map do |inventory|
                 { id: inventory.product.id, model: inventory.product.model, inventory: inventory.quantity }
               end
    }
  end
end
