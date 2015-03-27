
class OpentokDetail < ActiveRecord::Base

	DEFAULT_FIELDS_TO_DISPLAY = ['id','event_id', 'user_id', 'session_id', 'token', 'token_expires_at','api_key','ticket_code','artist_first_name','artist_last_name','role','uploaded_media']

	belongs_to :ticket,  foreign_key: :ticket_code

	before_save :set_default

	def set_default
		self.token_expires_at = Time.now + 24.hours if self.token_expires_at.blank?
	end

	def attributes
		@display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
	end

	def api_key
		OPENTOK_API_KEY
	end

	def artist_first_name
		@event.user.first_name
	end

	def artist_last_name
		@event.user.last_name
	end

	def uploaded_media
		hangout_uploaded_media = []	
		var=@event.hangout_medias.where(:trashed=>0)
		return hangout_uploaded_media if var.blank?
		var.each do |hm|
			hangout_uploaded_media << {:url=>hm.url,:media_type=>hm.media_type,:user_id=>hm.user_id}
		end
		hangout_uploaded_media
	end

	def role
		if @ticket.blank? then
			nil
		else
			@ticket.opentok_role
		end
	end

	## associations ##
	belongs_to :user
	belongs_to :event

	# validates :opentok_role,
	# :inclusion => { :in => [ "subscriber", "moderator", "publisher" ]},
	# :presence => true

	def self.persist_fields
		['user_id', 'event_id', 'session_id', 'token', 'token_expires_at','ticket_code']
	end


	## Initialization
	after_initialize :init

	def init
		@event= self.event
		@ticket=Ticket.where(:ticket_token=>self.ticket_code).first
	end

end
