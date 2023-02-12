# frozen_string_literal: true

# == Schema Information
#
# Table name: stores
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_stores_on_name  (name) UNIQUE
#
require 'rails_helper'

RSpec.describe Store, type: :model do
  subject { Store.create(name: 'ALDO test') }

  it 'is valid with a unique name' do
    expect(subject).to be_valid
  end

  it 'is invalid without a name' do
    subject.name = nil
    expect(subject).to_not be_valid
  end

  it 'is invalid with a non unique name' do
    Store.create(name: 'ALDO test')
    expect(subject).to_not be_valid
  end
end
