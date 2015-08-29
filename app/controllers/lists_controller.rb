class ListsController < ApplicationController
  def show
    # TODO reduce database access count
    @deliveries = Delivery.where(user: @user_id).order(date: :desc)

=begin
    deliveries.each_with_index do |deliver, i_deliveries|
      youtubes = Youtube.joins("LEFT JOIN users_youtubes ON #{deliver[:id]}=users_youtubes.delivery_id WHERE youtubes.id=users_youtubes.youtube_id").select('youtubes.videoId, youtubes.title')
      samples[i_deliveries] = youtubes
      # deliveries[i_deliveries]['youtubes'] = youtubes
    end
    # render json: deliveries
    render json: samples
=end


    # @deliveries = Delivery
    #                   .joins('LEFT JOIN users_youtubes ON deliveries.id=users_youtubes.delivery_id LEFT JOIN youtubes ON users_youtubes.youtube_id=youtubes.videoId')
    #                   .where(user: @user_id)
    #                   .order(date: :desc)
    # .select('deliveries.date, youtubes.videoId, youtubes.title')
    # render json: @deliveries

    # @deliveries = Delivery.where(user: @user_id).order(date: :desc)
    # render json: @deliveries
  end
end
