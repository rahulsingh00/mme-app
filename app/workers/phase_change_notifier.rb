require 'erubis'
require 'time'
class PhaseChangeNotifier
  include Sidekiq::Worker
  sidekiq_options queue: :phase_change_mail_queue, :retry => false

  def perform(user_id , user_email, phase_id)
    puts "start :: processing #{self.class} for user : #{user_id}"

    user_id_array = []

    ##send emails to users who shared/liked/played an artist's media
    User.find(user_id).network_activity_logs_for_user.each do |nw|
    	user_id_array << nw.from_user_id
    end

## send email to ticket buyers also
   User.find(user_id).events.each do |ev|
   	  ev.tickets.each do |tickt|
   	  	user_id_array << tickt.user_id
   	  end
   	end

    user_id_array = user_id_array.uniq
    #user_array= User.where( :id => user_id_array, :trashed =>0)
    user_array= User.where(:id=>user_id_array,:trashed=>0).where('email <> ?',user_email)

## email to supporters
    user_array.each do |u|
 		Pony.mail(:to => u.email, :subject => 'MME UPDATE', :body => "Artist id #{user_id}  moved to funding phase with your support" )   	
    end

## email to the artist
    Pony.mail(:to => user_email, :subject => 'MME Update', :body => 'congratulationss!!! you have moved to funding phase')
    puts "end :: email sent to #{user_id}"
  end
end