require 'erubis'
require 'time'
class NewUserMailNotifier
  include Sidekiq::Worker
  sidekiq_options queue: :new_user_mail_queue, :retry => false

  def perform(user_email)
    puts "start :: processing #{self.class} for email : #{user_email}"        
    Pony.mail(:to => user_email, :subject => 'MME Registration', :body => 'Thank you for Joining us.')
    puts "end :: email sent to #{user_email}"
  end
end