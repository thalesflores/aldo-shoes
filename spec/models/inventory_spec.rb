# frozen_string_literal: true

# == Schema Information
#
# Table name: inventories
#
#  id         :bigint           not null, primary key
#  quantity   :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :bigint           not null
#  store_id   :bigint           not null
#
# Indexes
#
#  index_inventories_on_product_id               (product_id)
#  index_inventories_on_store_id                 (store_id)
#  index_inventories_on_store_id_and_product_id  (store_id,product_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#  fk_rails_...  (store_id => stores.id)
#
require 'rails_helper'

RSpec.describe Inventory, type: :model do
  let(:store) { create(:store) }
  let(:product) { create(:product) }
  subject { Inventory.create(store:, product:) }

  it 'is valid with a store and product' do
    expect(subject).to be_valid
  end

  it 'is invalid with a non duplicated store and product' do
    Inventory.create(store:, product:)
    expect(subject).to_not be_valid
  end
end
