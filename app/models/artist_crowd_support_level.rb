class ArtistCrowdSupportLevel < ActiveRecord::Base

  before_save :set_default, :trash_old_phase
  after_save :phase_record_is_unique

  DEFAULT_FIELDS_TO_DISPLAY = ['id', 'artist_id', 'crowd_id','crowd_doer_level_id','activated_at','deactivated_at']

  def attributes
    @display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
  end

  def set_default
    self.activated_at =Time.now unless self.activated_at    
  end

  def trash_old_phase
    criteria = {:artist_id => self.artist_id , :crowd_id=>self.crowd_id ,:trashed =>0}
    self.class.update_all({:trashed => 1 , :deactivated_at => Time.now}, criteria)
  end

  ## associations ##
  belongs_to :user
  belongs_to :vw_artist
  

  ## validations ##

  def validate_time_stamps
    if !activated_at.blank? && activated_at < Time.now then
      errors.add(:invalid_date, "activated_at can not be a past date")
    end
    #if  (!deactivated_at.blank? && deactivated_at < Time.now) then
    #   errors.add(:invalid_date," deactivated_at can not be a past date")
    #end
    if !activated_at.blank? && !deactivated_at.blank? && activated_at > deactivated_at then
      errors.add(:invalid_date,"activated_at can not be future to deactivated_at")
    end
  end

  def phase_record_is_unique
    unless ArtistCrowdSupportLevel.where(:artist_id => self.artist_id, :crowd_id=>self.crowd_id, :trashed=>0).count ==0
      errors.add(:invalid_crowd_level_record,"there can not be two active phase of a user at same time")
    end
  end


  
  # 0-Active; 1-Inactive(Deleted)
  validates :trashed, :inclusion => { :in => [0, 1] }, :presence => true
  validate :validate_time_stamps

  def self.persist_fields
    [ "artist_id", "crowd_id","crowd_doer_level_id","activated_at","deactivated_at","trashed"]
  end

  ## Initialization
  after_initialize :init

  def init
    self.trashed = 0 if self.trashed.blank?
  end

end
