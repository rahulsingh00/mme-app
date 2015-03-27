class PlaylistSong < ActiveRecord::Base

  DEFAULT_FIELDS_TO_DISPLAY = ['id', 'media_id','meta_data','title','url','media_type','artist_info','is_media_trashed']

  def attributes
    @display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
  end


  ## associations ##
  belongs_to :user
  belongs_to :playlist
  belongs_to :media

  ## validations ##

  # 0-Active; 1-Inactive(Deleted)
  validates :trashed, :inclusion => { :in => [0, 1] }, :presence => true

  def artist_info
    artist_data={}
    return artist_data if @user.blank?

    artist_data[:first_name]=@user.first_name
    artist_data[:last_name]=@user.last_name
    artist_data[:user_id]=@user.id
    artist_data[:avatar]=@user.avatar
    artist_data
  end

  def title
    @media.title
  end

  def is_media_trashed
    @media.trashed==0 ? false :true
  end


  def url
    is_media_trashed ? "" : @media.url
  end

  def media_type
    @media.media_type    
  end

  def meta_data
    @media.meta_data
  end

  def self.persist_fields
    [ "user_id", "media_id","playlist_id"]
  end

  ## Initialization
  after_initialize :init

  def init
    self.trashed = 0 if self.trashed.blank?
    @media =Media.find(self.media_id)
    @user= @media.user
  end

end
