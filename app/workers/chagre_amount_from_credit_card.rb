require 'erubis'
require 'time'
class ChargeCreditCard
  include Sidekiq::Worker
  sidekiq_options queue: :charge_cc_queue, :retry => false

  def perform(stripe_customer_id, amount, currency='usd')
    puts "start :: processing #{self.class} for stripe user : #{stripe_customer_id} "

    payment_detail = PaymentDetail.find_by_stripe_customer_id_trashed(stripe_customer_id, 0)

    if(!payment_detail.blank?) then
      begin
        charge= charge_card(stripe_customer_id ,amount, currency)

        if !charge.blank? then
          payment_detail.update_attributes({:status=>'c'})

          ## email to the artist
          user_email= User.find(user_id).email
          Pony.mail(:to => user_email, :subject => 'Credit Card charged', :body => "Thanks!!! Your Credit Card associlated with customer_id #{stripe_customer_id} has been charged succuessfuly with amount $#{amount}" )  if !user_email.blank?

          puts "end :: email sent to #{user_id}"


        else
          logger.error self.class+"_Could not charge card for stripe_customer_id #{stripe_customer_id}"
          Pony.mail(:to => user_email, :subject => 'falied to charge Credit card', :body => "We Failed to charge Credit card associlated with the customer_id #{stripe_customer_id} " )  if !user_email.blank?
        end


      rescue Exception => e
        if !(payment_detail.update_attributes({:status=>'f',:falied_reason=>e.message})) then
          logger.error self.class+"_Could not update Payment for stripe_customer_id #{stripe_customer_id}"
        end

      end
    end



    ## email to the artist
    Pony.mail(:to => artist_email, :subject => 'MME Update', :body => "congratulationss!!! You have recieved a pledging of amount $#{amount} from user #{user_id}" )
    puts "end :: email sent to #{user_id}"
  end
end