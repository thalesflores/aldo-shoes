# frozen_string_literal: true

# == Schema Information
#
# Table name: products
#
#  id         :bigint           not null, primary key
#  category   :string           default("shoes"), not null
#  model      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_products_on_model  (model) UNIQUE
#
class Product < ApplicationRecord
  validates :model, uniqueness: true
  validates :model, presence: true
end
