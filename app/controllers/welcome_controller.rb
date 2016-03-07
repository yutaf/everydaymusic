class WelcomeController < ApplicationController
  skip_before_action :check_logged_in
  before_action :set_facebook_app_id
  def index
    if is_logged_in?
      redirect_to '/list'
      return
    end

    @user = User.new
    @password = Password.new
  end

  def create_user
    @user = User.new(user_params)
    @password = Password.new(password_params)

    @user.valid?
    @password.valid?

    @error_messages = @user.errors.full_messages.concat(@password.errors.full_messages)

    if @error_messages.count == 0
      #TODO sign up
    else
      render 'index'
    end
  end

  private
  def set_facebook_app_id
    @facebook_app_id = ENV['FACEBOOK_APP_ID']
  end
  def user_params
    params.require(:user).permit(:email)
  end
  def password_params
    params.require(:password).permit(:password, :password_confirmation)
  end
end
