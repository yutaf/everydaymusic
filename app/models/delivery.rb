class Delivery < ActiveRecord::Base
  belongs_to :user
  has_one :delivery_date
end
