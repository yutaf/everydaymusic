class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private
  # is this right manner?
  def is_logged_in?
    authcookie = cookies[:auth]
    if authcookie.blank?
      return false
    end
    redis = Redis.new(host: ENV['REDIS_HOST']);
    user_id = redis.hget('auths', authcookie);
    if user_id.blank?
      return false
    end
    authsecret = redis.hget("user:#{user_id}", 'auth')
    if authcookie != authsecret
      return false
    end

    return true
  end
end
