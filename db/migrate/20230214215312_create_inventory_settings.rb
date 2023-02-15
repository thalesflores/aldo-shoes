# frozen_string_literal: true

class CreateInventorySettings < ActiveRecord::Migration[7.0]
  def change
    create_table :inventory_settings do |t|
      t.references :inventory, null: false, foreign_key: true
      t.integer :low_quantity, default: 10, null: false
      t.integer :high_quantity, default: 100, null: false

      t.timestamps
    end
  end
end
