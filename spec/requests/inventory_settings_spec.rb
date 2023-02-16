require 'swagger_helper'

RSpec.describe 'inventory_settings', type: :request do
  path '/stores/{id}/products/{product_id}/inventories/settings' do
    patch('inventory settings updated') do
      tags 'Inventory Settings'
      consumes 'application/json'

      parameter name: 'id', in: :path, type: :string, description: 'id'
      parameter name: 'product_id', in: :path, type: :string, description: 'product_id'
      parameter name: 'quantity', in: :body, schema: {
        type: :object,
        properties: {
          low_quantity: { type: :integer },
          high_quantity: { type: :integer }
        }
      }

      response(200, 'successful') do
        let!(:inventory) { create(:inventory) }
        let!(:store) { inventory.store }
        let!(:product) { inventory.product }

        let(:id) { store.id }
        let(:product_id) { product.id }
        let(:quantity) { { low_quantity: 1, high_quantity: 10 } }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        run_test!
      end
    end
  end
end
