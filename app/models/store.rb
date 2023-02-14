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
class Store < ApplicationRecord
  has_many :inventories, dependent: :restrict_with_exception
  has_many :products, through: :inventories

  validates :name, uniqueness: true
  validates :name, presence: true
end
