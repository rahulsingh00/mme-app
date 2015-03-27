class User < ActiveRecord::Base

  #  attr_accessor :curr_phase

  has_secure_password


  after_commit :after_commit_callback, :on => :create

  def after_commit_callback
    #TODO: Create a Phase_ledger with activity-audition.
  end

  DEFAULT_FIELDS_TO_DISPLAY = ['id', 'first_name', 'last_name', 'email', 'phone_number',
  'avatar', 'bg_image', 'artist_card_bg_image' , 'bio', 'desc', 'user_type', 'stage_name', 'stats','phase_id' , 'total_tickets','phase_relevant_data','images','liked_songs','liked_artists']

  def attributes
    @display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
  end


  #####Remove This stats as it is a part of phase_relevant_data
  def stats
    { # 1- Play; 2-Like; 3-Share
      :shares => self.network_activity_logs_for_user.group_by(&:activity_type)[3].blank? ? 0 : self.network_activity_logs_for_user.group_by(&:activity_type)[3].size,
      :likes => self.network_activity_logs_for_user.group_by(&:activity_type)[2].blank? ? 0 : self.network_activity_logs_for_user.group_by(&:activity_type)[2].size,
      :plays => self.network_activity_logs_for_user.group_by(&:activity_type)[1].blank? ? 0 : self.network_activity_logs_for_user.group_by(&:activity_type)[1].size,
    }
  end

  ## array of media liked by user
  def liked_songs
    array_songs=[]
    self.network_activity_logs_by_user.select(:object_id).where(:activity_type=>2,:object_type=>"Media").as_json.uniq.each do |song|
      array_songs << song["object_id"]
    end
    array_songs
  end

  ## array of artists liked by the user
  def liked_artists
    array_artists=[]
    self.network_activity_logs_by_user.select(:object_id).where(:activity_type=>2,:object_type=>"User").as_json.uniq.each do |artist|
      array_artists << artist["object_id"]
    end
    array_artists
  end

  def images
    self.medias.where(:trashed=>0,:media_type=>0)
  end

  def phase_relevant_data
    phase_relevant_data = {}
    @curr_phase = self.phase_ledgers.last

    if @curr_phase.phase ==1
      # 1- Play; 2-Like; 3-Share
      phase_relevant_data[:shares] = self.network_activity_logs_for_user.group_by(&:activity_type)[3].blank? ? 0 : self.network_activity_logs_for_user.group_by(&:activity_type)[3].size
      phase_relevant_data[:likes] = self.network_activity_logs_for_user.group_by(&:activity_type)[2].blank? ? 0 : self.network_activity_logs_for_user.group_by(&:activity_type)[2].size
      phase_relevant_data[:plays] = self.network_activity_logs_for_user.group_by(&:activity_type)[1].blank? ? 0 : self.network_activity_logs_for_user.group_by(&:activity_type)[1].size
    end

    if @curr_phase.phase ==2 then
      event_tickets=Event.joins(:tickets).where('events.user_id'=>self.id , 'tickets.status'=>['booked','pending','viewing','used'])
      phase_relevant_data[:total_tickets]=(event_tickets.blank? ? 0 : event_tickets.count)
      phase_relevant_data[:events]=self.events.where("trashed=0 and  start_time > '#{Time.now}'")
    end

    if @curr_phase.phase ==3 then
      phase_relevant_data[:number_of_supporters]=self.number_of_supporters
      @artist_goal=self.artist_goal
      phase_relevant_data[:pledged_amount]=@artist_goal.blank? ? 0.0 : @artist_goal.raised_amount
      phase_relevant_data[:goal_aomunt]=@artist_goal.blank? ? 0.0 : @artist_goal.goal_amount
      ## add funding amount and count to the hash
    end
    phase_relevant_data

  end

  def phase_id
    #Its an invalid case to have nil phase information , still to avoid error
    #Once data is properly populated raise an error in this case
    #@curr_phase = self.phase_id
    #@curr_phase.blank? ? (self.phase_ledgers.last.blank? ? 1 : self.phase_ledgers.last.phase) : @curr_phase
    self.phase_ledgers.last
  end

  def playlists
    play_lists= {}
    PlaylistSong.find(:all, :conditions=>{:user_id=>self.id, :trashed=>0}).each do |pl|
      if play_lists[pl.playlist_id].blank? then
        play_lists[pl.playlist_id]=[pl]
      else
        play_lists[pl.playlist_id] << pl
      end
    end
    play_lists
  end

  def total_tickets
    @curr_phase = self.phase_ledgers.last


    if @curr_phase.phase  < 2 then
      0
    else
      event_tickets=Event.joins(:tickets).where('events.user_id'=>self.id , 'tickets.status'=>['booked','pending','viewing','used'])
      event_tickets.blank? ? 0 : event_tickets.count
    end
  end

  def number_of_supporters
    self.artist_recieving_payment_details.where(:trashed=>0).count
  end

  def number_of_users_who_bought_tickets_for_user
    @curr_phase = self.phase_ledgers.last
    if @curr_phase.phase < 2 then
      0
    else
      #query to find total number
    end
  end

  def user_events
    self.events.where('events.trashed = ? and events.start_time > ?',0,Time.now).order(:created_at)
  end

  def supporter_levels
    crowd_levles=CrowdDoerLevel.where(:trashed=>0)
    crowd_levles_fin= []
    crowd_role_chosen= self.crowd_role_chosen
    crowd_role_chosen="" if crowd_role_chosen.blank?
    chosen_levels= crowd_role_chosen.split(',').map { |x| x.to_i }
    crowd_levles.each do |crc|
      cl=crc.as_json
      if cl['id'].in?(chosen_levels) then
        cl['is_selected']=true
      else
        cl['is_selected']=false
      end
      crowd_levles_fin << cl
    end
    crowd_levles_fin
  end

  ## associations ##
  has_one :address, :autosave => true
  has_many :medias
  # has_many :social_connects
  has_one :twitter_connect, -> { where("network_type = 1") }, :class_name => "SocialConnect", :autosave => true
  has_one :facebook_connect, -> { where("network_type = 2") }, :class_name => "SocialConnect", :autosave => true
  has_many :phase_ledgers , :autosave => true
  has_many :network_activity_logs_by_user, :class_name => 'NetworkActivityLog', :foreign_key => "from_user_id"
  has_many :network_activity_logs_for_user, :class_name => 'NetworkActivityLog', :foreign_key => "for_user_id"
  #:finder_sql => proc { "select network_activity_logs.* from network_activity_logs  where for_user_id = #{self.id}" }

  has_many :events ,:autosave =>true
  has_many :tickets ,:autosave => true

  has_many :playlists
  has_many :playlist_songs ,:through=>:playlists

  has_many :user_making_payment_details, :class_name => 'PaymentDetail', :foreign_key => "user_id"
  has_many :artist_recieving_payment_details, :class_name => 'PaymentDetail', :foreign_key => "artist_id"

  has_one :artist_goal, :dependent => :destroy, :autosave => true
  accepts_nested_attributes_for :artist_goal, :allow_destroy => true

  has_many :rewards , :through=>:artist_goals

  has_many :opentok_details
  has_many :hangout_medias

  scope :artist_users, -> { where("user_type in (1,2,3)") }
  scope :crowd_users, -> { where(:user_type => 0) }

  ## validations ##
  validates :first_name, :last_name, :stage_name,
  :length => {:maximum => 20, :too_long => "%{count} characters is the maximum allowed"}

  validates :bio,
  :length => {:maximum => 512, :too_long => "%{count} characters is the maximum allowed"}

  validates :desc,
  :length => {:maximum => 1024, :too_long => "%{count} characters is the maximum allowed"}


  #validates :password_digest,
   # :presence => true,
    #:length => {:minimum => 3, :too_short => "%{count} characters is the maximum allowed",
#                :maximum => 512, :too_long => "%{count} characters is the maximum allowed"}

  validates :email,
  :presence => true,
  :length => {:maximum => 50, :too_long  => "%{count} characters is the maximum allowed"},
  :uniqueness => {:case_sensitive => false}

  # 0-Normal(Crowd); 1-Solo; 2-Band; 3-Freak
  validates :user_type, :inclusion => { :in => [0, 1, 2, 3] }, :presence => true

  # 0-Active; 1-Inactive(Deleted)
  validates :trashed, :inclusion => { :in => [0, 1] }, :presence => true

  # validates_presence_of :stage_name, :if => :artist?
  validates_length_of :stage_name, :maximum => 20, :if => :artist?
  validates_length_of :bio, :maximum => 512, :if => :artist?
  validates_length_of :desc, :maximum => 1024, :if => :artist?

  def artist?
    self.user_type.to_i != 0
  end

  def self.persist_fields
    #[  "first_name", "last_name", "email", "phone_number", "avatar", "bg_image", "bio", "desc", "user_type", "stage_name" ]
    [  "first_name", "last_name", "email", "phone_number", "password", "avatar", "artist_card_bg_image" ,"bg_image", "bio", "desc", "user_type", "stage_name" ]
  end

  ##  Initialization
  after_initialize :init

  def init
    self.user_type = 0 if self.user_type.blank?
    self.trashed = 0 if self.trashed.blank?
  end

  def to_s
    self.first_name + " " + self.last_name
  end
end
