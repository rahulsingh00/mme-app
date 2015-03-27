class VwNwActivityCount < ActiveRecord::Base

  DEFAULT_FIELDS_TO_DISPLAY = ['object_id', 'activity_type', 'object_type', 'activity_count']

  def attributes
    @display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
  end

end
