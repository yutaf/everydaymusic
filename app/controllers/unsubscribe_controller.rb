class UnsubscribeController < ApplicationController
  skip_before_action :init
  def index
    unsubscribe_key = params[:key]
    if unsubscribe_key.blank?
      return
    end
    redis = Redis.new(host: ENV['REDIS_HOST'])
    user_id = redis.hget('unsubscribe_keys', unsubscribe_key)
    if user_id.blank?
      return
    end
    user = User.find(user_id)
    if user.update(is_active: false)
      redis.hdel('unsubscribe_keys', unsubscribe_key)
    end
  end
end
