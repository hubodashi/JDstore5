# == Schema Information
#
# Table name: products
#
#  id          :integer          not null, primary key
#  title       :string
#  description :text
#  quantity    :integer
#  price       :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  image       :string
#

class Product < ApplicationRecord
  has_many :favorites
  has_many :users, through: :favorites, source: :user
  mount_uploader :image, ImageUploader
  acts_as_list
end
