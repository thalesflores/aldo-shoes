# frozen_string_literal: true

class CreateStores < ActiveRecord::Migration[7.0]
  def change
    create_table :stores do |t|
      t.string :name, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
