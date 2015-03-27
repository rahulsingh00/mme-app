class VwMedia < ActiveRecord::Base

  DEFAULT_FIELDS_TO_DISPLAY = ['id', 'user_id', 'title', 'desc', 'url', 'media_type', 'meta_data','stats','artist_info']


  def attributes
    @display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
  end

  def artist_info  	
  	{:first_name=>self.first_name, :last_name=>self.last_name, :user_id=>self.user_id, :avatar=>self.avatar, :artist_card_bg_image=>self.artist_card_bg_image,:phase_id=>self.phase_id}
  end

  def stats  	
  	{:likes=>self.likes.to_i,:shares=>self.shares.to_i,:plays=>self.plays.to_i,:raised_amount=>self.raised_amount}
  end

end
