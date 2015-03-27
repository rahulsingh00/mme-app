class VwPlaylist < ActiveRecord::Base

  #DEFAULT_FIELDS_TO_DISPLAY = ['id', 'user_id', 'title', 'desc', 'url', 'media_type', 'meta_data','stats','artist_info']
  DEFAULT_FIELDS_TO_DISPLAY = ['id', 'media_id','meta_data','title','url','media_type','artist_info','is_media_trashed','stats']


  def attributes
    @display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
  end

  def artist_info  	
  	{:first_name=>self.artist_first_name, :last_name=>self.artist_last_name, :user_id=>self.artist_id, :avatar=>self.artist_avatar,:artist_card_bg_image=>self.artist_card_bg_image}
  end

  def is_media_trashed
    self.url.blank? ? true :false
  end

  def stats  	
  	{:likes=>self.likes.to_i,:shares=>self.shares.to_i,:plays=>self.plays.to_i}
  end

end
