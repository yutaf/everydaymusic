class DeliveriesController < ApplicationController
  skip_before_action :check_logged_in
  def show
    @delivery = Delivery.find_by(id: params[:id])
    if @delivery.blank?
      #TODO Render error page
      location = '/'
      if is_logged_in?
        location = '/list'
      end
      redirect_to location
      return
    end
    @is_logged_in = is_logged_in?
  end
end