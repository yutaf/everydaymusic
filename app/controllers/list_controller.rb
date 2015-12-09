class ListController < ApplicationController
  def index
    # TODO reduce database access count
    @deliveries = Delivery.where(user: @user_id, is_delivered: true).order(id: :desc)
  end
end
