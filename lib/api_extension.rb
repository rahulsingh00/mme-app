class Array
  def to_ahash
    Hash[*self.collect { |v| [v, v]}.flatten]
  end
end

module RestHelpers

  def parse_csv_as_int_array(value, default_value=[])
    ret_value = value.split(",").collect{|e| e.to_i }.compact.uniq unless value.blank?
    ret_value = default_value if ret_value.blank?
    ret_value
  end

  def parse_csv_as_float_array(value, default_value=[])
    ret_value = value.split(",").collect{|e| e.to_f }.compact.uniq unless value.blank?
    ret_value = default_value if ret_value.blank?
    ret_value
  end

  def parse_csv_as_str_array(value, default_value=[])
    ret_value = value.split(",").collect{|e| e.to_s.strip unless e.blank?}.compact.uniq unless value.blank?
    ret_value = default_value if ret_value.blank?
    ret_value
  end

  def parse_or_default_to(value, default_value=nil)
    ret_value = (value.blank?) ? default_value : value
    ret_value
  end

  def filter_params(params, fields)
    params.select{|key, value| fields.include?(key.to_s)}
  end

  def raise_rest_error(message)
    logger.error message
    throw :error, :status => 422, :message => message
  end

  def raise_rest_error_with_status(status, message) 
    logger.error message   
    throw :error, :status => status, :message => message
  end

  def check_and_authenticate_user(current_user)
    raise_rest_error_with_status 404, "User Not Found" if !User.exists?(current_user)
    current_user
  end

  def generate_random_string(size = 8)
    charset = %w{ 2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z}
    (0...size).map{ charset.to_a[rand(charset.size)] }.join
  end

  def get_from_redis (key)
    REDIS.get key
  end

  def mget_from_redis (keys)
    REDIS.mget keys
  end

  def write_to_redis(key , data)
    REDIS.set key, data
  end

end
