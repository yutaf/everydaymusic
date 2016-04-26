class LogoutController < ApplicationController
  def index
    newauthsecret = MyString.create_random_uniq_str
    oldauthsecret = @redis.hget("user:#{@user_id}", 'auth')
    @redis.multi do |multi|
      multi.hset("user:#{@user_id}", 'auth', newauthsecret)
      multi.hset('auths', newauthsecret, @user_id)
      multi.hdel('auths', oldauthsecret)
    end

    redirect_to root_path
  end
end
