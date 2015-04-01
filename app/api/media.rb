require 'api_extension'
require 'api_decorator'

class Media < Grape::API

  helpers RestHelpers
  # use ApiDecorator

  # version 'v1', :using => :header, :vendor => 'mme', :format => :json, :strict => true
  before do
    header['Access-Control-Allow-Origin'] = '*'
    header['Access-Control-Request-Method'] = '*'
  end

  # rescue_from :all do |error|
  #   logger.error "API << #{env['REQUEST_METHOD']} #{env['PATH_INFO']} -- #{error.class.name} -- #{error.message}"
  #   logger.error "API << Last error's backtrace:\n#{error.backtrace.join("\n")}"
  #   headers = { 'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => '*', 'Access-Control-Request-Method' => '*' }
  #   rack_response({ error: [error.class.name], message: [error.message] }.to_json, 500, headers)
  # end


  resource 'medias' do
    desc "Get top media", {
      :params =>
      {
        "result_size" => { :desc => "Result Size; Default - 20", :type => "long" }
      }
    }


    # get "/topsongs" do

    #   ids=VwNwActivityCount.select("object_id, sum(activity_count) as s").where(:object_type=>"Media").group(:object_id).order("sum(activity_count) desc").limit((params[:result_size].to_i ==0) ? 20 : params[:result_size].to_i).pluck(:object_id)
    #   #records=Media.find_all_by_id(ids)
    #   records=Media.where(:id=>ids,:trashed=>0)
    #   sorted_records = ids.collect {|id| records.detect {|x| x.id == id}}

    #   raise_rest_error("no Record found!!!") if sorted_records.blank?

    #   status 200
    #   sorted_records

    # end

    ############## getting data from views ######################################
    get "/topsongs" do
      sorted_records = VwMedia.where('media_type=1').order("likes+plays+shares  desc").limit((params[:result_size].to_i ==0) ? 20 : params[:result_size].to_i)
      status 200
      sorted_records
    end

  end

  resource 'users' do

    desc "Create Media Record"
    post ":id/medias" do

      media_array = []
      @media=[]
      params["medias"].each { |media|
        media_params = filter_params(media, Media.persist_fields)
        logger.debug media_params
        media_params[:meta_data]= media_params["meta_data"].blank? ? "" : media_params["meta_data"].to_json
        media = Media.new media_params
        media.user_id = params[:id].to_i
        media_array << media
      }

      errors = nil
      Media.transaction do
        media_array.each { |media|

          if media.media_type ==2 then

            conditions, arguments = [], {}
            conditions << 'user_id = :user_id' << 'media_type = 2' << 'trashed = 0'
            arguments[:user_id] = media.user_id
            all_conditions = conditions.join(' AND ')

            existing_vedio= Media.all(
            :conditions => [all_conditions, arguments]
            )
            existing_vedio = [existing_vedio] unless existing_vedio.respond_to?(:each)
            vedio_ids = []
            existing_vedio.each do |v|
              logger.debug "existing vedio"
              logger.debug v.id
              vedio_ids << v.id.to_i
            end
            criteria = {:user_id => params[:id].to_i,:media_type => 2}
            criteria.merge!(:id => vedio_ids) unless vedio_ids.blank?
            Media.update_all({:trashed => 1}, criteria)
          end

          if !media.save
            errors = media.errors.full_messages
            raise ActiveRecord::Rollback
          end
          @media << media
        }
      end

      if !errors.blank?
        raise_rest_error_with_status(423, errors)
      end

      status 201
      @media
    end

    desc "Get Media for User", {
      :params =>
      {
        "id" => { :desc => "User Identifier", :type => "long" },
        "result_size" => { :desc => "Result Size; Default - 10", :type => "long" },
        "types" => { :desc => "CSV - 0-Image; 1-Audio; 2-Video", :type => "string" },
        "last_id" => { :desc => "Last seen Id", :type => "long" }
      }
    }
    # get ":id/medias" do
    #   user_id = params[:id].to_i
    #   result_size = parse_or_default_to(params[:result_size], 20).to_i
    #   types = parse_csv_as_int_array(params[:types])
    #   last_id = parse_or_default_to(params[:last_id], 0).to_i

    #   conditions, arguments = ["user_id = :user_id","trashed =0"], {:user_id => user_id}

    #   if last_id != 0
    #     conditions << 'id < :last_id'
    #     arguments[:last_id] = last_id
    #   end

    #   if !types.blank?
    #     conditions << 'media_type in (:media_types)'
    #     arguments[:media_types] = types
    #   end

    #   all_conditions = conditions.join(' AND ')

    #   media_list = Media.all(:conditions => [all_conditions, arguments], :limit => result_size, :order => "CREATED_AT DESC")
    #   {:medias => media_list}
    # end

   ########################## Reading from View #####################################
    get ":id/medias" do
      user_id = params[:id].to_i
      result_size = parse_or_default_to(params[:result_size], 20).to_i
      types = parse_csv_as_int_array(params[:types])
      last_id = parse_or_default_to(params[:last_id], 0).to_i

      conditions, arguments = ["user_id = :user_id"], {:user_id => user_id}

      if last_id != 0
        conditions << 'id < :last_id'
        arguments[:last_id] = last_id
      end

      if !types.blank?
        conditions << 'media_type in (:media_types)'
        arguments[:media_types] = types
      end

      all_conditions = conditions.join(' AND ')

      media_list = VwMedia.all(:conditions => [all_conditions, arguments], :limit => result_size, :order => "CREATED_AT DESC")
      {:medias => media_list}
    end



    desc "Delete Media Ids", {
      :params =>
      {
        "media_ids" => { :desc => "Media Identifier(s)", :type => "long" }
      }
    }
    delete ":id/medias/:media_ids" do
      media_ids = parse_csv_as_int_array(params[:media_ids])
      raise_rest_error_with_status(423,"No Media Found with the id") if media_ids.blank?

      criteria = {:user_id => params[:id] ,:trashed =>0}
      criteria.merge!(:id => media_ids) unless media_ids.blank?

      Media.update_all({:trashed => 1}, criteria)
      status 200
      {}
    end

  end
end
