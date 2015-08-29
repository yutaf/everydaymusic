class User < ActiveRecord::Base
  has_many :deliveries
  has_many :youtubes, through: :deliveries
end
