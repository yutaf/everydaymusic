class ListController < ApplicationController
  def index
    # TODO reduce database access count
    @deliveries = Delivery.where(user: @user_id, is_delivered: true).order(id: :desc)
    user_redis = @redis.hgetall("user:#{@user_id}")
    timezone = user_redis['timezone'].to_i
    timezone_abs = timezone.abs
    operator = '-'
    if timezone < 0
        operator = '+'
    end
    hour = "%02d"%[timezone_abs]
    time = Time.zone.parse("2007-02-10 #{user_redis['delivery_time']} #{operator}#{hour}00")
    @delivery_time_local = time.strftime('%H:%M')
  end
end