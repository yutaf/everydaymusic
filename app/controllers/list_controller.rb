class ListController < ApplicationController
  def index
    # TODO reduce database access count
    @deliveries = Delivery.joins(:delivery_date).where(user: @user_id, is_delivered: true).order(id: :desc)
  end
end
