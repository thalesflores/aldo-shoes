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
FactoryBot.define do
  factory :store do
    name { Faker::Creature::Cat.name + rand(1..1000).to_s}
  end
end
