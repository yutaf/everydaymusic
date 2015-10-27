class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :init

  private
  def init
    if ! is_logged_in?
      redirect_to '/'
      return
    end

    set_locale
  end

  def is_logged_in?
    authcookie = cookies[:auth]
    if authcookie.blank?
      return false
    end
    @redis = Redis.new(host: ENV['REDIS_HOST'])
    @user_id = @redis.hget('auths', authcookie)
    if @user_id.blank?
      return false
    end
    authsecret = @redis.hget("user:#{@user_id}", 'auth')
    if authcookie != authsecret
      return false
    end

    return true
  end

  def set_locale
    @user_redis = @redis.hgetall("user:#{@user_id}")
    locale = @user_redis['locale'][0,2]

    case locale
      when 'ja', 'en'
        I18n.locale = locale
      else
        ;
    end
  end
end
