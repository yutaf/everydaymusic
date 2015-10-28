class LogoutController < ApplicationController
  def index
    newauthsecret = ('a'..'z').to_a.shuffle[0,8].join
    oldauthsecret = @redis.hget("user:#{@user_id}", 'auth')
    @redis.multi do |multi|
      multi.hset("user:#{@user_id}", 'auth', newauthsecret)
      multi.hset('auths', newauthsecret, @user_id)
      multi.hdel('auths', oldauthsecret)
    end

    redirect_to '/'
  end
end
