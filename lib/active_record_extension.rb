module ActiveRecordExtension
class ActiveRecord::Base
  def display_fields=(value)
    @display_fields = value.to_ahash
    @display_fields
  end

  def display_fields
    @display_fields
  end

  def self.raise_rest_error(message)
    throw :error, :status => 422, :message => message
  end

  def self.raise_rest_error_with_status(status, message)
    throw :error, :status => status, :message => message
  end
end
end