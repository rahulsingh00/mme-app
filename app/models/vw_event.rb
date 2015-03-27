class VwEvent < ActiveRecord::Base

  DEFAULT_FIELDS_TO_DISPLAY = ['id', 'user_id', 'title', 'description', 'image', 'total_seats', 'event_type','start_time','end_time','price_per_seat','available_seats','artist_avatar','artist_first_name','artist_last_name','opentok_session_id']


  def attributes
    @display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
  end

  def available_seats  	
  		(self.total_seats-self.tickets_sold)
  end

end
