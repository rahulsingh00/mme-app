class VwPayment < ActiveRecord::Base

  #DEFAULT_FIELDS_TO_DISPLAY = ['id', 'user_id', 'title', 'desc', 'url', 'media_type', 'meta_data','stats','artist_info']
  DEFAULT_FIELDS_TO_DISPLAY = ['artist_id', 'goal_amount','raised_amount','phase','uncharged_amount','uncharged_amount']


  def attributes
    @display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
  end  
end
