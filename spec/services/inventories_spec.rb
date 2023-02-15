# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Inventories, type: :service do
  include Deterministic
  describe '#update_inventory' do
    describe 'when passing a new store and product' do
      let(:store) { 'Aldo Test Store' }
      let(:model) { 'Shoe test' }
      let(:inventory_quantity) { 10 }
      let(:params) { { store:, model:, inventory: inventory_quantity } }
      it 'creates the store, the product and add the inventory total' do
        result = Inventories.update_inventory(params)

        expect(result).to be_a Deterministic::Result::Success

        result_content = result.value

        expect(result_content[:inventory]).to be_a Inventory
        expect(result_content[:store]).to be_a Store
        expect(result_content[:product]).to be_a Product
      end

      it 'creates the store with the correct name' do
        result = Inventories.update_inventory(params)
        store_response = result.value[:store]

        expect(result).to be_a Deterministic::Result::Success
        expect(store_response.name).to eq(store)
      end

      it 'creates the product with the correct name' do
        result = Inventories.update_inventory(**params)
        product_response = result.value[:product]

        expect(result).to be_a Deterministic::Result::Success
        expect(product_response.model).to eq(model)
        expect(product_response.category).to eq('shoes')
      end

      it 'creates the inventory with the correct quantity and relations' do
        result = Inventories.update_inventory(**params)
        inventory_response = result.value[:inventory]
        product_response = result.value[:product]
        store_response = result.value[:store]

        expect(result).to be_a Deterministic::Result::Success
        expect(inventory_response.quantity).to eq(inventory_quantity)
        expect(inventory_response.store_id).to eq(store_response.id)
        expect(inventory_response.product_id).to eq(product_response.id)
      end
    end
  end

  describe '#transfer' do
    describe 'when the origin store has enough inventory quantity' do
      let(:product) { create(:product) }
      let(:origin_inventory) { create(:inventory, quantity: 10, product:) }
      let(:destination_inventory) { create(:inventory, quantity: 5, product:) }
      let(:params) do
        { from_store_inventory: origin_inventory, to_store_id: destination_inventory.store.id,
          product_id: origin_inventory.product_id, quantity: 2 }
      end
      let(:expected_response) do
        {
          origin_store: {
            id: origin_inventory.store.id,
            name: origin_inventory.store.name,
            product: {
              id: origin_inventory.product.id,
              model: origin_inventory.product.model,
              inventory: 8
            }
          },
          destination_store: {
            id: destination_inventory.store.id,
            name: destination_inventory.store.name,
            product: {
              id: destination_inventory.product.id,
              model: destination_inventory.product.model,
              inventory: 7
            }
          }
        }
      end

      it 'transfers the inventory between the two stores' do
        result = Inventories.transfer(**params)

        expect(result).to be_a Deterministic::Result::Success
        expect(origin_inventory.reload.quantity).to eq(8)
        expect(destination_inventory.reload.quantity).to eq(7)

        result_content = result.value
        expect(result_content).to eq(expected_response)
      end
    end

    describe 'when the origin store tries to transfer more inventory than it has' do
      let(:product) { create(:product) }
      let(:origin_inventory) { create(:inventory, quantity: 10, product:) }
      let(:destination_inventory) { create(:inventory, quantity: 5, product:) }
      let(:params) do
        { from_store_inventory: origin_inventory, to_store_id: destination_inventory.store.id,
          product_id: origin_inventory.product_id, quantity: 11 }
      end

      it 'returns Failure with a error message' do
        result = Inventories.transfer(**params)

        expect(result).to be_a Deterministic::Result::Failure

        result_content = result.value
        expect(result_content[:message]).to eq("You can't transfer more units than you have in the inventory")
      end
    end

    describe 'when passed an invalid to_store_id' do
      let(:product) { create(:product) }
      let(:origin_inventory) { create(:inventory, quantity: 10, product:) }
      let(:params) do
        { from_store_inventory: origin_inventory, to_store_id: 0,
          product_id: origin_inventory.product_id, quantity: 1 }
      end

      it 'returns Failure with a error message' do
        result = Inventories.transfer(**params)

        expect(result).to be_a Deterministic::Result::Failure

        result_content = result.value
        expect(result_content[:message]).to eq('Destination store not found')
      end
    end
  end
end
