class WelcomeController < ApplicationController
  skip_before_action :check_logged_in
  def index
    if is_logged_in?
      redirect_to '/list'
      return
    end

    @facebook_app_id = ENV['FACEBOOK_APP_ID']
  end
end
