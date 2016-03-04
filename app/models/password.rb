class Password < ActiveRecord::Base
  belongs_to :user
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }
end
