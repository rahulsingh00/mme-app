class Playlist < ActiveRecord::Base

  before_save :set_default

  DEFAULT_FIELDS_TO_DISPLAY = ['id', 'user_id', 'playlist_name']

  def attributes
    @display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
  end

  def set_default
    self.playlist_name ="My Music" unless self.playlist_name
  end

  ## associations ##
  belongs_to :user

  has_many :playlist_songs

  ## validations ##
  validates :playlist_name,
  :length => {:maximum => 20, :too_long => "%{count} characters is the maximum allowed"}

  # 0-Active; 1-Inactive(Deleted)
  validates :trashed, :inclusion => { :in => [0, 1] }, :presence => true

  def self.persist_fields
    [ "user_id", "playlist_name"]
  end

  ## Initialization
  after_initialize :init

  def init
    self.trashed = 0 if self.trashed.blank?
  end

end
