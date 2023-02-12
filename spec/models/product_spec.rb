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
require 'rails_helper'

RSpec.describe Product, type: :model do
  subject { Product.create(model: 'ALDO product') }

  it 'is valid with a unique model' do
    expect(subject).to be_valid
  end

  it 'is invalid without a model' do
    subject.model = nil
    expect(subject).to_not be_valid
  end

  it 'is invalid with a non unique model' do
    Product.create(model: 'ALDO product')
    expect(subject).to_not be_valid
  end
end
