class HangoutMessage < ActiveRecord::Base

  DEFAULT_FIELDS_TO_DISPLAY = ['id', 'user_id','event_id','message_body','message_type','is_artist','created_at']

  def attributes
    @display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
  end


  ## associations ##
  belongs_to :user
  belongs_to :event

  ## validations ##
  validates :message_body,
    :length => {:maximum => 2048, :too_long => "%{count} characters is the maximum allowed"}

  
  # 0-Active; 1-Inactive(Deleted)
  validates :trashed, :inclusion => { :in => [0, 1] }, :presence => true
  # text,media
  validates :message_type, :presence => true

  
  def self.persist_fields
    [ "user_id", "event_id", "message_body", "message_type" , "is_artist"]
  end

  ## Initialization
  after_initialize :init

  def init
    self.trashed = 0 if self.trashed.blank?
    #@user= self.user
  end

end
