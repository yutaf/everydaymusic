class DeliveriesController < ApplicationController
  skip_before_action :init
  def show
    @is_logged_in = is_logged_in?
    @delivery = Delivery.find(params[:id])
  end
end