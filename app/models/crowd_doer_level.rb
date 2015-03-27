class CrowdDoerLevel < ActiveRecord::Base

  # before_save :set_default

  DEFAULT_FIELDS_TO_DISPLAY = ['id', 'level_name', 'shares','funding','perks','max_participants']

  def attributes
    @display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
  end

  def set_default
    
  end

  ## associations ##
  

  ## validations ##
  
  # 0-Active; 1-Inactive(Deleted)
  validates :trashed, :inclusion => { :in => [0, 1] }, :presence => true

  def self.persist_fields
    [ "level_name", "shares","funding","perks","max_participants","trashed"]
  end

  ## Initialization
  after_initialize :init

  def init
    self.trashed = 0 if self.trashed.blank?
  end

end
