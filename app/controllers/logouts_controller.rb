class LogoutsController < ApplicationController
  def show
    newauthsecret = ('a'..'z').to_a.shuffle[0,8].join
    oldauthsecret = @redis.hget("user:#{@user_id}", 'auth')
    @redis.hset("user:#{@user_id}", 'auth', newauthsecret)
    @redis.hset('auths', newauthsecret, @user_id)
    @redis.hdel('auths', oldauthsecret)

    redirect_to '/'
    return
  end
end
