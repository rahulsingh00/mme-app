require 'api_extension'
require 'api_decorator'

class Share < Grape::API

  helpers RestHelpers
  # use ApiDecorator

  # version 'v1', :using => :header, :vendor => 'mme', :format => :json, :strict => true
  before do
    header['Access-Control-Allow-Origin'] = '*'
    header['Access-Control-Request-Method'] = '*'
  end

  # rescue_from :all do |error|
  #   logger.error "API << #{env['REQUEST_METHOD']} #{env['PATH_INFO']} -- #{error.class.name} -- #{error.message}"
  #   logger.error "API << Lastt error's backtrace:\n#{error.backtrace.join("\n")}"
  #   headers = { 'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => '*', 'Access-Control-Request-Method' => '*' }
  #   rack_response({ error: [error.class.name], message: [error.message] }.to_json, 500, headers)
  # end

  resource 'users' do

    desc "get liked songs by user"
    get ":logged_in_user_id/liked_items" do
      liked_objects={:songs=>[],:artists=>[]}
      NetworkActivityLog.where(:from_user_id=>params[:logged_in_user_id].to_i,:activity_type=>2).each{ |object|
        (liked_objects[:songs]<< object.object_id).uniq! if object.object_type=="Media"
        (liked_objects[:artists]<< object.object_id).uniq! if object.object_type=="User"
      }

      liked_objects[:songs].sort!
      liked_objects[:artists].sort!
      status  200
      liked_objects
    end

    desc "Share"
    post ":id/:object_type/:object_id/:network_id/:activity_type" do
      logger.info "#{params[:activity_type]} by user #{params[:id]}"
      logger.info "#{params}"

      user = User.find(params[:id])
      raise_rest_error "User Not Found with id #{params[:id]}" if user.blank?

      from_user_id = params[:id].to_i
      object_id = params[:object_id].to_i
      object_type = params[:object_type].to_s.downcase
      activity_type = params[:activity_type].to_s.downcase
      network = params[:network_id].to_i
      reachability_count = params[:reachability_count].blank? ?  1 : params[:reachability_count].to_i

      object = object_type.capitalize.constantize.find(object_id)

      raise_rest_error "could not find object with id #{object_id}" if object.blank?

      if(object_type=="media") then
        for_user_id=object.user_id
      elsif (object_type=="user") then
        for_user_id=object.id
      end


      activity_log = NetworkActivityLog.new :from_user_id => from_user_id, :object => object, :dest_object => user ,:for_user_id=>for_user_id, :reachability_count=> reachability_count.to_i

      # 1- Play; 2-Like; 3-Share
      if (activity_type == "plays")
        activity_log.activity_type = 1
      elsif activity_type == "likes"
        activity_log.activity_type = 2
        raise_rest_error("User has already liked this Artist/Media") if !activity_log.unique_like?
      elsif activity_type =="shares"
        activity_log.activity_type = 3
        if network == 1
          activity_log.dest_object = user.twitter_connect
        elsif network == 2
          activity_log.dest_object = user.facebook_connect
        end
      end

      raise_rest_error_with_status(423, activity_log.errors.full_messages) if !activity_log.save

      artist_id= NetworkActivityLog.find(activity_log.id).for_user_id
      logger.debug "artist id is #{artist_id}"

      artist=  VwArtist.find(artist_id.to_i)
      response_hash={}
      response_hash[:artist_stats]=artist.stats

      ## getting the crowd stats
      login_id = params[:id].to_i
       if (!login_id.blank?  && login_id > 0) then
        crowd_activity = VwCrowdActivity.where(:from_user_id=> login_id, :for_user_id=> artist_id.to_i)
        shares,likes,plays,funding=0,0,0,0.0
        crowd_activity.each do |ca|
          shares+=ca.sum.to_i if ca.activity == "shares"
          likes+=ca.sum.to_i if ca.activity == "likes"
          plays+=ca.sum.to_i if ca.activity == "plays"
          funding+=ca.sum.to_f if ca.activity == "funding"
        end
        crowd_stats={"pledged_amount"=>funding,"likes"=>likes,"plays"=>plays,"shares"=>shares}
      else
        crowd_stats={"pledged_amount"=>0,"likes"=>0,"plays"=>0,"shares"=>0}
      end
      response_hash[:crowd_stats]=crowd_stats

      ## Re-calculate the crowd Doer level
      CrowdDoerLevelUpdater.perform_async([from_user_id.to_i] , for_user_id)
      status 201
      response_hash.as_json
    end

  end
end
