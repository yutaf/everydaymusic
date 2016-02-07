class PoliciesController < ApplicationController
  skip_before_action :check_logged_in
  def privacy
  end
end
