class SocialConnect < ActiveRecord::Base

  DEFAULT_FIELDS_TO_DISPLAY = ['id', 'user_id', 'network_id', 'network_type', 'access_token', 'screen_name']

  def attributes
    @display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
  end

  ## associations ##
  belongs_to :user

  ## validations # 1-Twitter; 2-Facebook; 0-Email
  validates :network_type, :inclusion => { :in => [0, 1, 2] }, :presence => true
  validates :network_id, :access_token, :presence => true

  def self.persist_fields
    [ "user_id", "network_id", "network_type", "access_token", "screen_name", "secret" ]
  end
end