class WelcomeController < ApplicationController
  skip_before_action :check_logged_in
  before_action :set_facebook_app_id
  def index
    if is_logged_in?
      redirect_to '/list'
      return
    end

    @user = User.new
  end

  def create_user
    @user = User.new(user_params)
    @user.valid?
    if @user.valid?
      ;
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
end
