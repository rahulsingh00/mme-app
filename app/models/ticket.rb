
class Ticket < ActiveRecord::Base

	DEFAULT_FIELDS_TO_DISPLAY = ['id', 'user_id', 'event_id', 'ticket_token', 'booked_at', 'payment_txn_id', 'discount_token', 'selling_price', 'status','opentok_role']

	before_save :set_default

	def set_default
		self.ticket_token = generate_ticket_token if self.ticket_token.blank?
		self.booked_at=Time.now if self.booked_at.blank?
		#TODO :: the status has to be handeled properly once payment is implemented
		self.status ="booked" if self.status.blank?
		#self.opentok_role=OpenTok::RoleConstants::SUBSCRIBER if self.opentok_role.blank?
	end

	def attributes
		@display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
	end

	## associations ##
	belongs_to :user
	belongs_to :event
	#has_one :payment ,:auto_save=>true

	has_many :opentok_details, primary_key: :ticket_token

	## validations ##
	validates :ticket_token,
	#:presence => true,
	:length => {:maximum => 20, :too_long => "%{count} characters is the maximum allowed"},
	:uniqueness => {:case_sensitive => false}


	validates :status,
	:inclusion => { :in => ["pending","booked","cancelled","viewing","used","invalid"] },
	:presence => true

	validates :user_role,
	:inclusion=> { :in =>["artist","crowd"] },
	:presence=>true

	validates :opentok_role,
	:inclusion => { :in => [ "subscriber", "moderator", "publisher" ]},
	:presence => true


	validate :validate_ticket_price

	validate :validate_ticket_booking

	def validate_ticket_booking
		errors.add(:no_tickets_available, "All the tickets are sold out !!!")	if (Ticket.where(:user_role=>'artist',:event_id=>self.event_id,:status=>["pending","booked","cancelled","viewing","used"]).count.to_i) >= self.event.total_seats.to_i
	end


	def validate_ticket_price
		errors.add(:invalid_price_per_seat,"Ticket price can not be negative") unless  selling_price >= 0
	end

	#keep a prepopulated lookup for token , for zero chance of collision of token codes
	def generate_ticket_token(size = 8)
		charset = %w{ 2 3 4 6 7 9 A C D E F G H J K M N P Q R T U V W X Y Z}
		(0...size).map{ charset.to_a[rand(charset.size)] }.join
	end

	def self.persist_fields
		['user_id', 'event_id', 'ticket_token', 'booked_at', 'payment_txn_id', 'discount_token', 'selling_price', 'status','opentok_role','used_by_user_id']
	end
  ## Initialization
  after_initialize :init

  def init
    self.user_role = 'crowd' if self.user_role.blank?   
    self.selling_price=0 if self.selling_price.blank? 
    self.opentok_role=OpenTok::RoleConstants::SUBSCRIBER if self.opentok_role.blank?
  end


end
