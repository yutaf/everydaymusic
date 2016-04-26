class DeliveriesController < ApplicationController
  skip_before_action :check_logged_in
  def show
    @delivery = Delivery.find_by(id: params[:id])
    if @delivery.blank?
      #TODO Render error page
      location = root_path
      if is_logged_in?
        location = list_path
      end
      redirect_to location
      return
    end

    @is_logged_in = is_logged_in?
    @meta_title = "#{@delivery.title} | #{MY_APP['meta']['site_name']}"
    @og_image = "https://i.ytimg.com/vi/#{@delivery.video_id}/hqdefault.jpg"

    if is_logged_in?
      user = User.find(@user_id)
      @checked = user.artists.exists?(@delivery.artist_id)
    end
  end
end