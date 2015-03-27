class VwCrowdActivity < ActiveRecord::Base

  DEFAULT_FIELDS_TO_DISPLAY = ['from_user_id','for_user_id', 'activity','sum']

  def attributes
    @display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
  end

end
