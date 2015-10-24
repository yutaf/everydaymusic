class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :initialize

  private
  def initialize
    # Check logged in
    if ! is_logged_in?
      redirect_to '/login'
      return
    end

    # Set locale value to session
    if session[:locale].nil?
      user = User.find(@user_id)
      session[:locale] = user[:locale][0,2]
    end
    case session[:locale]
      when 'ja', 'en'
        I18n.locale = session[:locale]
      else
        ;
    end
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
end
