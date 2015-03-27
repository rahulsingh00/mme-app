class Event < ActiveRecord::Base

	DEFAULT_FIELDS_TO_DISPLAY = ['id', 'user_id', 'title', 'description','image', 'total_seats', 'event_type','start_time','end_time','price_per_seat','available_seats','artist_avatar','artist_first_name','artist_last_name','opentok_session_id']

	before_save :set_default

	def set_default
		self.total_seats =1 if (self.total_seats.blank? || self.total_seats <=0)
		self.price_per_seat=0 if self.price_per_seat.blank?
		#		self.opentok_session_id = create_opentok_session if self.opentok_session_id.blank?
	end

	def attributes
		@display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
	end

	## associations ##
	belongs_to :user
	has_many :tickets
	has_many :opentok_details
	has_many :hangout_medias

	## validations ##
	#validates :venue,
	#:presence => true,
	#:length => {:maximum => 512, :too_long => "%{count} characters is the maximum allowed"},
	#:uniqueness => {:case_sensitive => false}

	validates :description,
	:presence =>true ,
	:length => {:maximum => 512, :too_long => "%{count} characters is the maximum allowed"}

	validates :title,
	:presence => true,
	:length => {:maximum => 256, :too_long => "%{count} characters is the maximum allowed"}

	validates :opentok_session_id,
	:presence=>true,
	:length=>{:maximum=>512, :too_long=>"%{count} characters is the maximum allowed"}

	# 0-Active; 1-Inactive(Deleted)
	validates :trashed, :inclusion => { :in => [0, 1] }, :presence => true

	#validate Time stamps
	validate :validate_time_stamps
	validate :validate_ticket_price

	def validate_time_stamps
		errors.add(:invalid_start_time, "Invalid Event start time ") unless ( !self.start_time.blank? && self.start_time > Time.now )
		errors.add(:invalid_end_time, "Invalid Event end time.") unless ( !self.end_time.blank? && self.end_time > Time.now )
		errors.add(:invalid_event_window, "Event end time can not be before start time") unless self.end_time > self.start_time
	end

	def validate_ticket_price
		errors.add(:invalid_price_per_seat, "Event price can not be negative") unless  self.price_per_seat >= 0
	end

	def available_seats
		self.total_seats-Ticket.where(:user_role=>'crowd',:event_id=>self.id,:status=>["pending","booked","cancelled","viewing","used"]).count
	end

	def artist_avatar
		@user.avatar
	end

	def artist_first_name
		@user.first_name
	end

	def artist_last_name
		@user.last_name
	end

	def self.persist_fields
		[ 'user_id', 'title', 'description', 'venue','image', 'total_seats', 'event_type','start_time','end_time','price_per_seat' ]
	end

	## Initialization
	after_initialize :init

	def init
		self.trashed = 0 if self.trashed.blank?		
		@user=self.user
	end

end
