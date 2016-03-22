class User < ActiveRecord::Base
  has_many :deliveries
  has_and_belongs_to_many :artists
  has_one :password

  validates :email, presence: true, uniqueness: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  validates_associated :password
end
