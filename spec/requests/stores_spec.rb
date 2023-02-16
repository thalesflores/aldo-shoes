require 'swagger_helper'

RSpec.describe 'stores', type: :request do
  path '/stores' do
    get('list stores') do
      tags 'Stores'

      response(200, 'successful') do
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        let!(:inventory) { create(:inventory) }

        run_test!
      end
    end
  end

  path '/stores/{id}' do
    get('show store') do
      tags 'Stores'
      parameter name: 'id', in: :path, type: :integer, description: 'store id'

      response(200, 'successful') do
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        let!(:inventory) { create(:inventory) }
        let!(:id) { inventory.store.id }

        run_test!
      end

      response(404, 'not found') do
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {}
          }
        end

        let!(:id) { 0 }

        run_test!
      end
    end
  end
end
