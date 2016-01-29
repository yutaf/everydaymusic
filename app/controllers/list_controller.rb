class ListController < ApplicationController
  def index
    # TODO reduce database access count
    @deliveries = Delivery.where(user: @user_id, is_delivered: true).order(id: :desc)
    if @deliveries.size == 0
      user = User.select(:id, :timezone, :delivery_time).find(@user_id)
      artist_ids = user.artist_ids
      # render json: artist_ids
      if artist_ids.size == 0
        render action: :no_artist
      else
        timezone = user['timezone'].to_i
        timezone_abs = timezone.abs
        operator = '-'
        if timezone < 0
          operator = '+'
        end
        hour = "%02d"%[timezone_abs]

        utc_date = user['delivery_time'].strftime("%F %T")
        time = Time.zone.parse("#{utc_date} #{operator}#{hour}00")
        @delivery_time_local = time.strftime('%H:%M')
        render action: :welcome
      end
    end
  end
end