class InventorySettingsController < ApplicationController
  include Deterministic::Prelude

  before_action :find_inventory, only: [:edit]

  def edit
    InventorySettings.update_settings(@inventory, **update_params).match do
      Success() { |s| render json: { store: s }, status: 200 }
      Failure() { |f| render json: { message: f[:message] }, status: f[:code] || 422 }
    end
  end

  private

  def update_params
    params.permit(:low_quantity, :high_quantity)
  end

  def find_inventory
    @inventory = Inventory.find_by_store_and_product(params[:id], params[:product_id])

    raise ActiveRecord::RecordNotFound unless @inventory
  end
end
