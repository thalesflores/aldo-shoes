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
FactoryBot.define do
  factory :product do
    model { 'Nice shoe' }
    category { 'shoe' }
  end
end
