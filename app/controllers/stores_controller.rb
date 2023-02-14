class StoresController < ApplicationController
  def index
    stores = Store.includes(:inventories).includes(:products).all

    response = build_response(stores)
    render json: response
  end

  private

  def build_response(stores)
    stores.map do |store|
      {
        id: store.id,
        name: store.name,
        products: store.inventories.map do |inventory|
          { id: inventory.product.id, model: inventory.product.model, inventory: inventory.quantity }
        end
      }
    end
  end
end
