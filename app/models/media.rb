class Media < ActiveRecord::Base

  DEFAULT_FIELDS_TO_DISPLAY = ['id', 'user_id', 'title', 'desc', 'url', 'media_type', 'meta_data','stats']

  def attributes
    @display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
  end

  def stats
    { # 1- Play; 2-Like; 3-Share
      :shares => NetworkActivityLog.where(:object_id => self.id, :object_type => self.class.to_s, :activity_type => 3).count(1),
      :likes => NetworkActivityLog.where(:object_id => self.id, :object_type => self.class.to_s,:activity_type => 2).count(1),
      :plays => NetworkActivityLog.where(:object_id => self.id, :object_type => self.class.to_s,:activity_type => 1).count(1)
      }
  end

  ## associations ##
  belongs_to :user

  ## validations ##
  validates :url,
    :length => {:maximum => 512, :too_long => "%{count} characters is the maximum allowed"}

  validates :desc,
    :length => {:maximum => 512, :too_long => "%{count} characters is the maximum allowed"}

  validates :title,
    :presence => true,
    :length => {:maximum => 250, :too_long => "%{count} characters is the maximum allowed"}

  # 0-Active; 1-Inactive(Deleted)
  validates :trashed, :inclusion => { :in => [0, 1] }, :presence => true
  # 0-Image; 1-Audio; 2-Video
  validates :media_type, :inclusion => { :in => [0, 1, 2] }, :presence => true

  def self.persist_fields
    [ "user_id", "title", "desc", "url", "media_type", "meta_data" ]
  end

  ## Initialization
  after_initialize :init

  def init
    self.trashed = 0 if self.trashed.blank?
  end

end
