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
class Inventory < ApplicationRecord
  belongs_to :store
  belongs_to :product

  validates :store_id, uniqueness: { scope: :product_id }
  validates :quantity, presence: { message: 'quantity can not be null' }
end
