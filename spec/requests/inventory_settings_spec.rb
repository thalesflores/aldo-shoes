# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InventorySettingsController, type: :request do
  describe 'PATCH /stores/:id/products/:product_id/inventories/settings' do
    describe 'when passing low_quantity' do
      let!(:inventory) { create(:inventory) }
      let!(:store) { inventory.store }
      let!(:product) { inventory.product }
      let!(:inventory_settings) { inventory.inventory_setting }
      let!(:request_body) { { low_quantity: 2 } }
      let(:expected_response) do
        {
          store: {
            id: store.id,
            name: store.name,
            product: {
              id: product.id,
              model: product.model,
              inventory: inventory.quantity,
              inventory_settings: {
                high_quantity: inventory_settings.high_quantity,
                low_quantity: 2
              }

            }
          }
        }
      end

      it 'returns settings updated' do
        patch "/stores/#{store.id}/products/#{product.id}/inventories/settings", params: request_body

        expect(response).to have_http_status(200)
        expect(response.body).to eq(expected_response.to_json)
        expect(inventory_settings.reload.low_quantity).to eq(2)
      end
    end

    describe 'when passing high_quantity' do
      let!(:inventory) { create(:inventory) }
      let!(:store) { inventory.store }
      let!(:product) { inventory.product }
      let!(:inventory_settings) { inventory.inventory_setting }
      let!(:request_body) { { high_quantity: 30 } }
      let(:expected_response) do
        {
          store: {
            id: store.id,
            name: store.name,
            product: {
              id: product.id,
              model: product.model,
              inventory: inventory.quantity,
              inventory_settings: {
                high_quantity: 30,
                low_quantity: inventory_settings.low_quantity
              }

            }
          }
        }
      end

      it 'returns settings updated' do
        patch "/stores/#{store.id}/products/#{product.id}/inventories/settings", params: request_body

        expect(response).to have_http_status(200)
        expect(response.body).to eq(expected_response.to_json)
        expect(inventory_settings.reload.high_quantity).to eq(30)
      end
    end

    describe 'when passing invalid store' do
      let!(:inventory) { create(:inventory) }
      let!(:product) { inventory.product }
      let!(:request_body) { { high_quantity: 30 } }

      it 'returns not found' do
        patch "/stores/0/products/#{product.id}/inventories/settings", params: request_body

        expect(response).to have_http_status(404)
      end
    end

    describe 'when passing invalid product' do
      let!(:inventory) { create(:inventory) }
      let!(:store) { inventory.store }
      let!(:request_body) { { high_quantity: 30 } }

      it 'returns not found' do
        patch "/stores/#{store.id}/products/0/inventories/settings", params: request_body

        expect(response).to have_http_status(404)
      end
    end
  end
end
