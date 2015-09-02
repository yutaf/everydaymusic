class User < ActiveRecord::Base
  has_many :deliveries
  has_many :youtubes, through: :deliveries
  has_and_belongs_to_many :artists
end
