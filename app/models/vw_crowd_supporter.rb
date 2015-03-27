class VwCrowdSupporter < ActiveRecord::Base

  DEFAULT_FIELDS_TO_DISPLAY = ['crowd_id', 'crowd_first_name', 'crowd_last_name', 'crowd_email', 'artist_id', 'support_level','activated_at','crowd_avatar']

  belongs_to :vw_artist


  def attributes
    @display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
  end

 
end
