class Delivery < ActiveRecord::Base
  belongs_to :user
  belongs_to :youtube
end
