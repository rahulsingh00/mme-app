class VwBookedEvent < ActiveRecord::Base

	DEFAULT_FIELDS_TO_DISPLAY = ['event_id', 'user_id', 'title', 'description', 'total_seats', 'event_type','start_time','end_time','price_per_seat','available_seats','artist_avatar','artist_first_name','artist_last_name','opentok_session_id','booked_tickets']


	def attributes
		@display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
	end

	def available_seats
		(self.total_seats-self.tickets_sold)
	end

	def booked_tickets
		self.ticket_roles="" if self.ticket_roles.blank?
		arr=self.tickets.split(',').zip(self.ticket_roles.split(','))
		tickets_booked=[]
		arr.each do |ticket|
			tickets_booked << {:code=>ticket[0],:role=>ticket[1]}
		end
		tickets_booked
	end

end
