class WelcomeController < ApplicationController
  skip_before_action :init
  def index
    if is_logged_in?
      #TODO render account link
      #TODO render logout link

      #TODO render list link
    else
      #TODO render facebook login button
    end
  end
end
