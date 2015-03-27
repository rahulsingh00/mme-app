class Address < ActiveRecord::Base

  DEFAULT_FIELDS_TO_DISPLAY = ['id', 'line_1', 'line_2', 'city', 'state', 'country', 'zip_code', 'user_id']

  def attributes
    @display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
  end

  ## associations ##
  belongs_to :user

  ## validations ##
  validates :line_1, :line_2,
    :length => {:maximum => 512, :too_long => "%{count} characters is the maximum allowed"}

  validates :city, :state, :country,
    :length => {:maximum => 100, :too_long => "%{count} characters is the maximum allowed"}

    #TODO: Validate zip_code, User.

  def self.persist_fields
    [ "line_1", "line_2", "city", "state", "country", "zip_code", "user_id" ]
  end
end
