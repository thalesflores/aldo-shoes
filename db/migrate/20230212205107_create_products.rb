# frozen_string_literal: true

class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :model, null: false, index: { unique: true }
      t.string :category, default: 'shoes', null: false

      t.timestamps
    end
  end
end
