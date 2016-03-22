class WelcomeController < ApplicationController
  skip_before_action :check_logged_in
  before_action :set_facebook_app_id
  include MyString
  def index
    if is_logged_in?
      redirect_to '/list'
      return
    end

    @user = User.new
    @user.build_password
  end

  def login
    user_params_requested = user_params
    @user = User.find_by(email: user_params_requested[:email])
    password_params_requested = password_params

    if @user.nil? || @user.password.authenticate(password_params_requested[:password]) == false
      @error_messages = [(t 'account.errors.messages.login_failed')]
      @user = User.new(user_params_requested)
      @user.build_password
      render :index
      return
    end

    # login
    log_user_in(@user)

    redirect_to '/list'
    return
  end

  def signup
    user_params_requested = user_params

    locale = ENV['DEFAULT_LOCALE']
    if request.headers['HTTP_ACCEPT_LANGUAGE'].present?
      locale = request.headers['HTTP_ACCEPT_LANGUAGE'].scan(/\A[a-z]{2}/).first
    end

    # delivery_time
    timezone = user_params_requested[:timezone].to_i
    timezone_abs = timezone.abs
    operator = '+'
    if timezone < 0
      operator = '-'
    end
    diff_hour = "%02d"%[timezone_abs]
    utc_date = Time.zone.parse("2015-03-08 #{ENV['DEFAULT_DELIVERY_TIME']} #{operator}#{diff_hour}00")
    delivery_time = utc_date.strftime("%T")

    user_params_additional = {locale: locale, delivery_time: delivery_time, is_active: true}
    user_params_new = user_params_requested.merge(user_params_additional)
    @user = User.new(user_params_new)
    @user.build_password(password_params)

    if @user.save
      # login
      log_user_in(@user)

      redirect_to '/signup/artists'
    else
      # Remove "is invalid" message by validates_associated of User model
      @user.errors.delete :password

      @error_messages = @user.errors.full_messages.concat(@user.password.errors.full_messages)
      render 'index'
      return
    end
  end

  private
  def log_user_in(user_object)
    authsecret = MyStringer.create_random_uniq_str
    user_hash = user_object.attributes
    user = user_hash.merge({auth: authsecret})

    redis = Redis.new(host: ENV['REDIS_HOST'])

    redis.multi do |multi|
      multi.mapped_hmset("user:#{user_object.id}", user)
      multi.hset('auths', authsecret, user_object.id)
    end
    cookies[:auth] = {value: authsecret, expires: 1.year.from_now}
  end

  def set_facebook_app_id
    @facebook_app_id = ENV['FACEBOOK_APP_ID']
  end
  def user_params
    params.require(:user).permit(:email, :timezone)
  end
  def password_params
    params.require(:password).permit(:password, :password_confirmation)
  end
end
