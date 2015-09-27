class User < ActiveRecord::Base
  has_many :deliveries
  has_and_belongs_to_many :artists

  validates :email, presence: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
end
