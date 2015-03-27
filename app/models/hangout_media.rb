class HangoutMedia < ActiveRecord::Base

  DEFAULT_FIELDS_TO_DISPLAY = ['id', 'user_id','event_id','url','media_type']

  def attributes
    @display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
  end


  ## associations ##
  belongs_to :user
  belongs_to :event

  ## validations ##
  validates :url,
    :length => {:maximum => 512, :too_long => "%{count} characters is the maximum allowed"}

  
  # 0-Active; 1-Inactive(Deleted)
  validates :trashed, :inclusion => { :in => [0, 1] }, :presence => true
  # 0-Image; 1-Audio; 2-Video
  validates :media_type, :inclusion => { :in => [0, 1, 2] }, :presence => true

  
  def self.persist_fields
    [ "user_id", "event_id", "url", "media_type" ]
  end

  ## Initialization
  after_initialize :init

  def init
    self.trashed = 0 if self.trashed.blank?
    #@user= self.user
  end

end
