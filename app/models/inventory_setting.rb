# == Schema Information
#
# Table name: inventory_settings
#
#  id            :bigint           not null, primary key
#  high_quantity :integer          default(100), not null
#  low_quantity  :integer          default(10), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  inventory_id  :bigint           not null
#
# Indexes
#
#  index_inventory_settings_on_inventory_id  (inventory_id)
#
# Foreign Keys
#
#  fk_rails_...  (inventory_id => inventories.id)
#
class InventorySetting < ApplicationRecord
  belongs_to :inventory
end
