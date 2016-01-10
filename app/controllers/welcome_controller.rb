class WelcomeController < ApplicationController
  skip_before_action :init
  def index
    if is_logged_in?
      redirect_to '/list'
    end

    @facebook_app_id = ENV['FACEBOOK_APP_ID']
    if request.env['HTTP_HOST'].end_with?('xip.io') || request.env['HTTP_HOST'].end_with?('vagrantshare.com')
      @facebook_app_id = ENV['FACEBOOK_APP_ID_DEVELOPMENT']
    end
  end
end
