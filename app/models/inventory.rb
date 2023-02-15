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

  has_one :inventory_setting

  validates :store_id, uniqueness: { scope: :product_id }
  validates :quantity, presence: { message: 'quantity can not be null' }

  after_create :create_settings

  scope :includes_relations, -> { includes(:store).includes(:product).includes(:inventory_setting) }

  class InsufficientQuantity < StandardError; end

  def self.find_by_store_and_product(store_id, product_id)
    where(store_id:, product_id:).includes_relations.first
  end

  def self.receive_transfer_suggestions_by_store_id(store_id)
    response = ActiveRecord::Base.connection.select_all <<-SQL
      WITH
      inventories_high_quantity AS (
        SELECT
          s.id AS store_id,
          s.name AS store_name,
          p.id AS product_id,
          p.model AS model,
          i.quantity,
          (i.quantity - ist.low_quantity) AS transfer_suggestion
        FROM inventories AS i
        INNER JOIN stores AS s ON s.id = i.store_id
        INNER JOIN products AS p ON p.id = i.product_id
        INNER JOIN inventory_settings AS ist ON ist.inventory_id = i.id
        WHERE i.quantity >= ist.high_quantity AND
          (i.quantity - ist.low_quantity) >= ist.low_quantity AND
          s.id != #{store_id}
      ),
        current_inventory_with_low_quantity AS (
          SELECT
            i.id AS inventory_id,
            p.id AS product_id,
            i.quantity AS inventory_quantity,
            (ist.high_quantity - i.quantity) AS max_transfer
          FROM inventories AS i
          INNER JOIN stores AS s ON s.id = i.store_id
          INNER JOIN products AS p ON p.id = i.product_id
          INNER JOIN inventory_settings AS ist ON ist.inventory_id = i.id
          where i.quantity <= ist.low_quantity AND s.id = #{store_id}
        )
      SELECT
        ihq.store_id,
        ihq.store_name,
        ihq.product_id,
        ihq.model as product_model,
        (CASE
          WHEN ciwlq.max_transfer >= ihq.transfer_suggestion THEN transfer_suggestion
          WHEN ciwlq.max_transfer < ihq.transfer_suggestion THEN ciwlq.max_transfer
        END) AS transfer_suggestion
      FROM inventories_high_quantity AS ihq
      INNER JOIN current_inventory_with_low_quantity AS ciwlq ON ihq.product_id = ciwlq.product_id;
    SQL

    response.to_a
  end

  def self.send_transfer_suggestions_by_store_id(store_id)
    response = ActiveRecord::Base.connection.select_all <<-SQL
      WITH
      inventories_low_quantity AS (
        SELECT
          s.id AS store_id,
          s.name AS store_name,
          p.id AS product_id,
          p.model AS model,
         (ist.high_quantity - i.quantity) AS max_transfer
        FROM inventories AS i
        INNER JOIN stores AS s ON s.id = i.store_id
        INNER JOIN products AS p ON p.id = i.product_id
        INNER JOIN inventory_settings AS ist ON ist.inventory_id = i.id
        WHERE i.quantity < ist.low_quantity AND s.id != #{store_id}
      ),
        current_inventory_with_high_quantity AS (
          SELECT
            s.id AS store_id,
            s.name AS store_name,
            p.id AS product_id,
            p.model AS model,
            (i.quantity - ist.low_quantity ) AS transfer_suggestion
          FROM inventories AS i
          INNER JOIN stores AS s ON s.id = i.store_id
          INNER JOIN products AS p ON p.id = i.product_id
          INNER JOIN inventory_settings AS ist ON ist.inventory_id = i.id
          where i.quantity >= ist.high_quantity AND s.id = #{store_id}
        )
      SELECT
        ilq.store_id,
        ilq.store_name,
        ilq.product_id,
        ilq.model as product_model,
        (CASE
          WHEN ciwhq.transfer_suggestion < ilq.max_transfer THEN ciwhq.transfer_suggestion
          WHEN ciwhq.transfer_suggestion >= ilq.max_transfer THEN ilq.max_transfer
        END) AS transfer_suggestion
      FROM current_inventory_with_high_quantity AS ciwhq
      INNER JOIN inventories_low_quantity AS ilq ON ilq.product_id = ciwhq.product_id;
    SQL

    response.to_a
  end

  private

  def create_settings
    InventorySetting.create(inventory: self)
  end
end
