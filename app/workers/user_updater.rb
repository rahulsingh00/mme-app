require 'erubis'
require 'time'
class UserUpdater
  include Sidekiq::Worker
  sidekiq_options queue: :user_update_queue, :retry => false

  def perform(user_id )
    puts "start :: processing #{self.class} for user : #{user_id} "

    user= User.find(user_id)
    REDIS.set("user_#{user_id}",user.as_json)

    puts "end :: user doc updated in redis"
  end
end