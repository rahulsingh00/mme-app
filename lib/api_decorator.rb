class ApiDecorator
  include RestHelpers

  def initialize(app)
    @app = app
  end

  def call(env)

    if env['REQUEST_METHOD'].upcase == 'GET'

      rack_request_query_hash = Rack::Utils.parse_nested_query(env['QUERY_STRING'])
      env['display_field_map'] = {}
      return @app.call(env) if rack_request_query_hash.blank? || rack_request_query_hash['fields'].blank?

      display_field_map = parse_and_group_display_fields(rack_request_query_hash)
      fields_to_display = display_field_map['fields']

      logger.info "==================================="
      logger.info "setting display_field_map env : " 
      logger.info  display_field_map.inspect
      logger.info "==================================="

      env['display_field_map'] = display_field_map
      app_response = @app.call(env)
      status, headers, bodies = *app_response

      if !fields_to_display.blank?
        bodies = bodies.map do |body|
          recursively_set_display_fields(display_field_map, body)
        end
      end
      app_response
    else
      @app.call(env)
    end

  end

  private
  def parse_and_group_display_fields(hash)
    expand_fields = hash.keys.grep /fields/
    espand_hash = expand_fields.inject({}) { |h,k| h[k] = hash[k] if hash.has_key?(k); h }

    display_field_map = {}
    espand_hash.each{|key,value|
      y = key.sub('_fields','__fields').split('__')
      ret_value = parse_csv_as_str_array(value)
      h = y.reverse.inject(ret_value) { |a, n| { n => a } }
      display_field_map.deep_merge!(h)
    }

    display_field_map
  end

  def recursively_set_display_fields(display_map, body)

    obj_array = [body]
    if body.class.to_s === 'Hash'
      obj_array = body.values.flatten
    elsif body.class.to_s === 'Array'
      obj_array = body.flatten
    end

    obj_array.each {|obj|

      if obj.respond_to?(:display_fields=) && !display_map['fields'].blank?
        cureated_list = display_map['fields'].collect{|e| e if obj.respond_to?(e) }.compact.uniq
        obj.display_fields = cureated_list if !cureated_list.blank?
      end

      display_map.keys.each { |key|
        if key == 'fields'
          next
        end

        if obj.class.to_s === 'Hash'
          obj_tmp = Hashie::Mash.new(obj)
          if obj_tmp.respond_to?(key)
            nested_objs = obj_tmp.send(key)
            recursively_set_display_fields(display_map[key], nested_objs) if !nested_objs.blank?
          end
        else
          if obj.respond_to?(key)
            nested_objs = obj.send(key)
            recursively_set_display_fields(display_map[key], nested_objs) if !nested_objs.blank?
          end
        end
      }
    }
  end

end
