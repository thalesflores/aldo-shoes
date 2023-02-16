require 'swagger_helper'

RSpec.describe 'inventory_transfers', type: :request do
  path '/stores/{id}/inventories/transfers' do
    post('Make an inventory transfer') do
      tags 'Inventory'
      consumes 'application/json'

      parameter name: 'id', in: :path, type: :integer, description: 'id'
      parameter name: 'transfer', in: :body, schema: {
        type: :object,
        properties: {
          product_id: { type: :integer },
          quantity: { type: :integer },
          destination_store: { type: :integer }
        },

        required: %w[product_id quantity destination_store]
      }

      response(201, 'inventory transfered') do
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        let!(:inventory_store_one) { create(:inventory, quantity: 10) }
        let!(:store_one) { inventory_store_one.store }
        let!(:product) { inventory_store_one.product }
        let!(:inventory_store_two) { create(:inventory, quantity: 1, product:) }
        let!(:store_two) { inventory_store_two.store }

        let(:id) { store_one.id }
        let(:transfer) { { product_id: product.id, quantity: 6, destination_store: store_two.id } }

        run_test!
      end

      response(422, 'inventory with not enouhg items') do
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        let!(:inventory_store_one) { create(:inventory, quantity: 10) }
        let!(:store_one) { inventory_store_one.store }
        let!(:product) { inventory_store_one.product }
        let!(:inventory_store_two) { create(:inventory, quantity: 1, product:) }
        let!(:store_two) { inventory_store_two.store }

        let(:id) { store_one.id }
        let(:transfer) { { product_id: product.id, quantity: 99, destination_store: store_two.id } }

        run_test!
      end

      response(404, 'destination store does not exist') do
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        let!(:inventory) { create(:inventory, quantity: 10) }
        let!(:store) { inventory.store }
        let!(:product) { inventory.product }

        let(:id) { store.id }
        let(:transfer) { { product_id: product.id, quantity: 99, destination_store: 0 } }

        run_test!
      end

      response(404, 'origin store does not exist') do
        after do |example|
          example.metadata[:response][:content] = { 'application/json' => {} }
        end

        let(:product) { create(:product) }
        let(:destination_store) { create(:store) }

        let(:id) { 0 }
        let(:transfer) { { product_id: product.id, quantity: 6, destination_store: destination_store.id } }

        run_test!
      end
    end
  end
end
