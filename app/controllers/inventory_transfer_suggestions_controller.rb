class InventoryTransferSuggestionsController < ApplicationController
  before_action :find_store, only: [:show]

  def show
    transfer_suggestions = Inventories.transfer_suggestions(store: @store)

    transfer_suggestions.match do
      Success() { |s| render json: { store: s }, status: 200 }
      Failure() { |f| render json: { message: f[:message] }, status: f[:code] || 422 }
    end
  end

  private

  def find_store
    @store = Store.find(params[:id])

    raise ActiveRecord::RecordNotFound unless @store
  end
end
