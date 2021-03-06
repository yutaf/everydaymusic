class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :check_logged_in, :set_locale, :set_meta_vars

  private
  def check_logged_in
    if ! is_logged_in?
      redirect_to root_path
      return
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

  def set_meta_vars
    @meta_title = MY_APP['meta']['site_name']
    @og_image = view_context.image_url('og-image.jpg')
  end

  def set_locale
    locale = ENV['DEFAULT_LOCALE']
    if params[:locale].present?
      locale = params[:locale]
    elsif @redis.present? && @redis.instance_of?(Redis)
      user_redis = @redis.hgetall("user:#{@user_id}")
      locale = user_redis['locale']
    elsif request.headers['HTTP_ACCEPT_LANGUAGE'].present?
      locale = request.headers['HTTP_ACCEPT_LANGUAGE'].scan(/\A[a-z]{2}/).first
    end

    locale = locale[0,2]
    case locale
      when 'ja', 'en'
        ;
      else
        locale = 'en'
    end
    I18n.locale = locale
  end
end
