require 'rails_helper'

RSpec.describe InventoryTransfersController, type: :request do
  describe 'POST /stores/:id/inventories/transfers' do
    describe 'when the store has enough stock' do
      let!(:inventory_store_one) { create(:inventory, quantity: 10) }
      let!(:store_one) { inventory_store_one.store }
      let!(:product) { inventory_store_one.product }
      let!(:inventory_store_two) { create(:inventory, quantity: 1, product:) }
      let!(:store_two) { inventory_store_two.store }
      let(:request_body) { { product_id: product.id, quantity: 6, destination_store: store_two.id } }

      let(:expected_response) do
        {
          transfer: {
            origin_store: {
              id: store_one.id,
              name: store_one.name,
              product: {
                id: product.id,
                model: product.model,
                inventory: 4
              }
            },
            destination_store: {
              id: store_two.id,
              name: store_two.name,
              product: {
                id: product.id,
                model: product.model,
                inventory: 7
              }
            }
          }
        }
      end

      it 'transfers the inventory quantity to another store' do
        post "/stores/#{store_one.id}/inventories/transfers", params: request_body

        expect(response).to have_http_status(201)
        expect(response.body).to eq(expected_response.to_json)
        expect(inventory_store_one.reload.quantity).to eq(4)
        expect(inventory_store_two.reload.quantity).to eq(7)
      end
    end

    describe "when the store hasn't enough stock" do
      let!(:inventory_store_one) { create(:inventory, quantity: 1) }
      let!(:store_one) { inventory_store_one.store }
      let!(:product) { inventory_store_one.product }
      let!(:inventory_store_two) { create(:inventory, quantity: 1, product:) }
      let!(:store_two) { inventory_store_two.store }
      let(:request_body) { { product_id: product.id, quantity: 6, destination_store: store_two.id } }
      let(:expected_response) { { message: "You can't transfer more units than you have in the inventory" } }

      it 'returns 422 code with error message' do
        post "/stores/#{store_one.id}/inventories/transfers", params: request_body

        expect(response).to have_http_status(422)
        expect(response.body).to eq(expected_response.to_json)
        expect(inventory_store_one.reload.quantity).to eq(1)
        expect(inventory_store_two.reload.quantity).to eq(1)
      end
    end

    describe "when the destination store doesn't exist" do
      let!(:inventory_store_one) { create(:inventory, quantity: 1) }
      let!(:store_one) { inventory_store_one.store }
      let!(:product) { inventory_store_one.product }
      let(:request_body) { { product_id: product.id, quantity: 6, destination_store: 0 } }
      let(:expected_response) { { message: 'Destination store not found' } }

      it 'returns 404 code with error message' do
        post "/stores/#{store_one.id}/inventories/transfers", params: request_body

        expect(response).to have_http_status(404)
        expect(response.body).to eq(expected_response.to_json)
        expect(inventory_store_one.reload.quantity).to eq(1)
      end
    end

    describe "when the origin store store doesn't exist" do
      let(:product) { create(:product) }
      let(:destination_store) { create(:store) }
      let(:request_body) { { product_id: product.id, quantity: 6, destination_store: destination_store.id } }
      let(:expected_response) { { message: 'Destination store not found' } }

      it 'returns 404' do
        post '/stores/0/inventories/transfers', params: request_body

        expect(response).to have_http_status(404)
      end
    end
  end
end
