class StoresController < ApplicationController
  def index
    stores = Store.includes(:inventories).includes(:products).all

    response = stores.map { |store| build_response(store) }
    render json: response
  end

  def show
    store = Store.find(params[:id])

    render json: build_response(store)
  end

  private

  def build_response(store)
    {
      id: store.id,
      name: store.name,
      products: store.inventories.map do |inventory|
                  { id: inventory.product.id, model: inventory.product.model, inventory: inventory.quantity }
                end
    }
  end
end
