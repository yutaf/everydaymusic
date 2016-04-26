class WelcomeController < ApplicationController
  skip_before_action :check_logged_in
  before_action :set_facebook_app_id
  def index
    if is_logged_in?
      redirect_to list_path
      return
    end

    @user = User.new
    @user.build_password

    # css class
    @hide_login = 'hide'
    @hide_signup = ''
    @switch_form_login_selected = ''
    @switch_form_signup_selected = 'switch-form-selected'

    if request.env['PATH_INFO'].scan(/\/login/).count > 0
      @hide_login = ''
      @hide_signup = 'hide'
      @switch_form_login_selected = 'switch-form-selected'
      @switch_form_signup_selected = ''
    end
  end

  def login
    user_params_requested = user_params

    @user = User.find_by(email: user_params_requested[:email])
    password_params_requested = password_params

    if @user.nil? || @user.password.nil? || @user.password.authenticate(password_params_requested[:password]) == false
      @login_error_messages = [(t 'account.errors.messages.login_failed')]
      @user = User.new(user_params_requested)
      @user.build_password

      # css class
      @hide_login = ''
      @hide_signup = 'hide'
      @switch_form_login_selected = 'switch-form-selected'
      @switch_form_signup_selected = ''
      render :index
      return
    end

    # login
    log_user_in(@user)

    redirect_to list_path
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

      redirect_to signup_artists_path
    else
      # Remove "is invalid" message by validates_associated of User model
      @user.errors.delete :password

      @signup_error_messages = @user.errors.full_messages.concat(@user.password.errors.full_messages)

      # css class
      @hide_login = 'hide'
      @hide_signup = ''
      @switch_form_login_selected = ''
      @switch_form_signup_selected = 'switch-form-selected'

      render :index
      return
    end
  end

  private
  def log_user_in(user_object)
    redis = Redis.new(host: ENV['REDIS_HOST'])
    authsecret = redis.hget("user:#{user_object.id}", 'auth')
    if authsecret.nil?
      authsecret = MyString.create_random_uniq_str
    end

    user_hash = user_object.attributes
    user = user_hash.merge({auth: authsecret})

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
