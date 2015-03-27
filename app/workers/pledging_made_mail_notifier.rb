require 'erubis'
require 'time'
class PledgingMadeMailNotifier
  include Sidekiq::Worker
  sidekiq_options queue: :pledging_mail_queue, :retry => false

  def perform(user_id , artist_id, amount, txn_id)
    puts "start :: processing #{self.class} for user : #{user_id} and artist : #{artist_id}"

    user_email = User.find(user_id).email
    artist_email = User.find(artist_id).email

    ## email to pledger

    Pony.mail(:to => user_email, :subject => 'MME UPDATE', :body => "Thank you for supporting the artist #{artist_id} By Pledging $#{amount}.Youre Transaction ID for the reference is : #{txn_id}" )


    ## email to the artist
    Pony.mail(:to => artist_email, :subject => 'MME Update', :body => "congratulationss!!! You have recieved a pledging of amount $#{amount} from user #{user_id}" )
    puts "end :: email sent to #{user_id}"
  end
end