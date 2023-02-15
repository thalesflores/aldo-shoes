require 'rails_helper'

RSpec.describe StoresController, type: :request do
  describe 'GET /stores' do
    describe 'when there is only one store' do
      let!(:inventory) { create(:inventory) }
      let!(:store) { inventory.store }
      let!(:product) { inventory.product }
      let!(:expected_response) do
        { stores: [{ id: store.id, name: store.name,
                     products: [{ id: product.id, model: product.model, inventory: inventory.quantity }] }] }
      end

      it 'returns success code with only ony store and its inventory' do
        get '/stores'

        expect(response).to have_http_status(200)
        expect(response.body).to eq(expected_response.to_json)
      end
    end
  end

  describe 'GET /stores/:id' do
    describe 'when passed a valid store id' do
      let!(:inventory) { create(:inventory) }
      let!(:store) { inventory.store }
      let!(:product) { inventory.product }
      let!(:expected_response) do
        { store: { id: store.id, name: store.name,
                   products: [{ id: product.id, model: product.model, inventory: inventory.quantity }] } }
      end

      it 'returns success code with the store and its inventory' do
        get "/stores/#{store.id}"

        expect(response).to have_http_status(200)
        expect(response.body).to eq(expected_response.to_json)
      end
    end

    describe 'when passed an invalid store id' do
      it 'returns not found' do
        get '/stores/0'

        expect(response).to have_http_status(404)
      end
    end
  end
end
