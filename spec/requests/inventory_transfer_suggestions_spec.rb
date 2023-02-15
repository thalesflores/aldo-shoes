require 'rails_helper'

RSpec.describe 'InventoryTransferSuggestions', type: :request do
  describe 'GET /show' do
    describe 'when the store needs transfer and could transfer' do
      let!(:inventory_to_receive) { create(:inventory, quantity: 2) }
      let!(:store) { inventory_to_receive.store }
      let!(:product) { inventory_to_receive.product }
      let!(:inventory_to_send) { create(:inventory, quantity: 130, store:) }
      let!(:inventory_with_extra_products) { create(:inventory, quantity: 101, product:) }
      let!(:store_with_extra_products) { inventory_with_extra_products.store }
      let!(:inventory_needing_extra_products) { create(:inventory, quantity: 1, product: inventory_to_send.product) }
      let!(:store_needing_extra_products) { inventory_needing_extra_products.store }
      let(:expected_response) do
        {
          store: {
            id: store.id,
            name: store.name,
            inventory_transfers_suggestions: {
              send_transfers: [
                {
                  store: {
                    id: store_needing_extra_products.id,
                    name: store_needing_extra_products.name
                  },
                  product: {
                    id: inventory_to_send.product.id,
                    model: inventory_to_send.product.model,
                    quantity: 99
                  }
                }
              ],
              receive_transfers: [
                {
                  store: {
                    id: store_with_extra_products.id,
                    name: store_with_extra_products.name
                  },
                  product: {
                    id: inventory_to_receive.product.id,
                    model: inventory_to_receive.product.model,
                    quantity: 91
                  }
                }
              ]
            }
          }
        }
      end

      it 'list stores and products which the current store could send or receive transfers' do
        get "/stores/#{store.id}/inventories/transfer_suggestions"

        expect(response).to have_http_status(200)
        expect(response.body).to eq(expected_response.to_json)
      end
    end

    describe 'when the store only needs transfer' do
      let!(:inventory_to_receive) { create(:inventory, quantity: 2) }
      let!(:store) { inventory_to_receive.store }
      let!(:product) { inventory_to_receive.product }
      let!(:inventory_with_extra_products) { create(:inventory, quantity: 101, product:) }
      let!(:store_with_extra_products) { inventory_with_extra_products.store }
      let(:expected_response) do
        {
          store: {
            id: store.id,
            name: store.name,
            inventory_transfers_suggestions: {
              send_transfers: [],
              receive_transfers: [
                {
                  store: {
                    id: store_with_extra_products.id,
                    name: store_with_extra_products.name
                  },
                  product: {
                    id: inventory_to_receive.product.id,
                    model: inventory_to_receive.product.model,
                    quantity: 91
                  }
                }
              ]
            }
          }
        }
      end

      it 'list store and product which the current store could receive transfers' do
        get "/stores/#{store.id}/inventories/transfer_suggestions"

        expect(response).to have_http_status(200)
        expect(response.body).to eq(expected_response.to_json)
      end
    end

    describe 'when the store only could send transfer' do
      let!(:inventory) { create(:inventory, quantity: 130) }
      let!(:store) { inventory.store }
      let!(:product) { inventory.product }
      let!(:inventory_needing_extra_products) { create(:inventory, quantity: 1, product:) }
      let!(:store_needing_extra_products) { inventory_needing_extra_products.store }
      let(:expected_response) do
        {
          store: {
            id: store.id,
            name: store.name,
            inventory_transfers_suggestions: {
              send_transfers: [
                {
                  store: {
                    id: store_needing_extra_products.id,
                    name: store_needing_extra_products.name
                  },
                  product: {
                    id: product.id,
                    model: product.model,
                    quantity: 99
                  }
                }
              ],
              receive_transfers: []
            }
          }
        }
      end

      it 'list store and product which the current store could send transfers' do
        get "/stores/#{store.id}/inventories/transfer_suggestions"

        expect(response).to have_http_status(200)
        expect(response.body).to eq(expected_response.to_json)
      end
    end

    describe 'when the store does not need transfer neither can transfer' do
      let!(:inventory) { create(:inventory, quantity: 30) }
      let!(:store) { inventory.store }
      let!(:product) { inventory.product }
      let!(:inventory_needing_extra_products) { create(:inventory, quantity: 1, product:) }
      let!(:store_needing_extra_products) { inventory_needing_extra_products.store }
      let(:expected_response) do
        {
          store: {
            id: store.id,
            name: store.name,
            inventory_transfers_suggestions: {
              send_transfers: [],
              receive_transfers: []
            }
          }
        }
      end

      it 'returns the suggestion list empty' do
        get "/stores/#{store.id}/inventories/transfer_suggestions"

        expect(response).to have_http_status(200)
        expect(response.body).to eq(expected_response.to_json)
      end
    end
  end
end
