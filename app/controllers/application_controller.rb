class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :before_action_login

  private
  def before_action_login
    # Check logged in
    authcookie = cookies[:auth]
    if authcookie.blank?
      redirect_to '/login'
      return
    end
    redis = Redis.new(host: ENV['REDIS_HOST']);
    @user_id = redis.hget('auths', authcookie);
    if @user_id.blank?
      redirect_to '/login'
      return
    end
    authsecret = redis.hget("user:#{@user_id}", 'auth')
    if authcookie != authsecret
      redirect_to '/login'
      return
    end

    # Set locale value to session
    if session[:locale].nil?
      user = User.find_by(@user_id)
      session[:locale] = user[:locale][0,2]
    end
    case session[:locale]
      when 'ja', 'en'
        I18n.locale = session[:locale]
      else
        ;
    end
  end
end
