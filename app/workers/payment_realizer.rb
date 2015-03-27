require 'erubis'
require 'time'
class PaymentRealizer
	include Sidekiq::Worker
	sidekiq_options queue: :payment_realization_queue, :retry => false

	def perform(artist_id )
		puts "start :: processing #{self.class} for artist : #{artist_id} "

		@goal= ArtistGoal.find_by_user_id(artist_id)

		puts "goal has not been set for this artist.Please check artist #{artist_id}" if @goal.blank?

		puts "Not achieved Goal..have to wait for some time artist id #{artist_id}........" if ( @goal.goal_amount > @goal.raised_amount )
		if ( @goal.goal_amount <= @goal.raised_amount ) then

			puts ("phase changed to signup phase for user #{user.email}")
			#Pony.mail(:to => user.email, :subject => 'You are now in contest phase ', :body => 'Congratulations!!! You have now moved to contest phase.')
			phase_param = {:user_id=>artist_id.to_i,:phase => 4}
			phase_ledger=PhaseLedger.new phase_param
			if !phase_ledger.save then
				puts("phase could not change for user #{user.email} "+phase_ledger.errors)
			else
				puts ("phase changed to signup phase for user #{user.email}")
			end

			puts "Goal achived by artist #{artist_id}...Going to charge credit cards now"

			@payment_details= PaymentDetail.where(:artist_id=>artist_id,:trashed=>0,:status=>['u','f'])
			if @payment_details.blank? then
				puts " There are not payment for the artist #{artist_id} cant not charge cards . Something went Wrong.Please check NOW!!!!"
			else
				@payment_details.each do |card|
					criteria = {:stripe_customer_id => card.stripe_customer_id }
					begin
						PaymentDetail.charge_card card.stripe_customer_id, card.amount ,card.currency						
						PaymentDetail.update_all({:status => 'c'}, criteria)						
						puts ("card charged successfully for customer #{card.stripe_customer_id}")
					rescue Stripe::CardError => e
						puts ("card payment failed for stripe  customer id #{card.stripe_customer_id} #{e.messages}")
						PaymentDetail.update_all({:status => 'f'}, criteria)
					end
				end
			end
		end

	end
end