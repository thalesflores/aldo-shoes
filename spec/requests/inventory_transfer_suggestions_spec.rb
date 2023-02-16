require 'swagger_helper'

RSpec.describe 'inventory_transfer_suggestions', type: :request do
  path '/stores/{id}/inventories/transfer_suggestions' do
    get('show suggestions about inventory transfers - to send and to receive') do
      tags 'Inventory'
      consumes 'application/json'
      parameter name: 'id', in: :path, type: :integer, description: 'store id'

      response(200, 'successful') do
        let!(:inventory_to_receive) { create(:inventory, quantity: 2) }
        let!(:store) { inventory_to_receive.store }
        let!(:product) { inventory_to_receive.product }
        let!(:inventory_to_send) { create(:inventory, quantity: 130, store:) }
        let!(:inventory_with_extra_products) { create(:inventory, quantity: 101, product:) }
        let!(:inventory_needing_extra_products) { create(:inventory, quantity: 1, product: inventory_to_send.product) }

        let(:id) { store.id }

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
