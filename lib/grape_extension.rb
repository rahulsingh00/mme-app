class Grape::API

  def self.get_param_headers
    {
      "Accept" => {
        :description => "Accept Header",
        :required => true,
        :allowableValues => {
          :valueType => "LIST",
          :values => [ "application/vnd.mme-v1+json", "application/vnd.mme-v1+xml" ]
        },
        :defaultValue => "application/vnd.mme-v1+json"
      }
    }
  end

  def self.post_param_headers
    {
      "Content-Type" => {
        :description => "Content Type",
        :required => false,
        :allowableValues => {
          :valueType => "LIST",
          :values => [ "application/json", "application/xml" ]
        },
        :defaultValue => "application/json"
      }
    }.merge(get_param_headers)
  end

end
