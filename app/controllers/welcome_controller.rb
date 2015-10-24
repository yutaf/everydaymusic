class WelcomeController < ApplicationController
  skip_before_action :init
  def index
    if is_logged_in?
      set_locale
      @header = 'header'
      @is_logged_in = true
      #TODO render list link
    else
      @header = 'header_plain'
      @is_logged_in = false
    end
  end
end
