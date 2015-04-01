require 'api_extension'
require 'api_decorator'

class Goal < Grape::API

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


  resource 'users' do

    desc "create goals"
    post '/:user_id/goals' do
      goals_params = filter_params(params,ArtistGoal.persist_fields)

      logger.debug goals_params
      @goal = ArtistGoal.find_by_user_id(params[:user_id])
      @goal= ArtistGoal.new goals_params if @goal.blank?
      @goal.goal_amount=goals_params["goal_amount"]


      ArtistGoal.transaction do
        Reward.trash_old_rewards @goal.user_id
        #criteria = {:user_id => user_id ,:trashed =>0}
        #self.update_all({:trashed => 1}, criteria)
        params.rewards.each do |reward|
          reward[:user_id]=params[:user_id].to_i
          reward_param=filter_params(reward,Reward.persist_fields)
          @goal.rewards << (Reward.new reward_param)
        end

        raise_rest_error_with_status(423, @goal.errors.full_messages) if !@goal.save
      end

      status 201
      @goal
    end

    desc "Get Goal for an Artist", {
      :params =>
      {
        "id" => { :desc => "User Identifier", :type => "long" },
      }
    }
    get ":id/goals" do
      user_id = params[:id].to_i
      conditions, arguments = ["artist_goals.user_id = :user_id"], {:user_id => user_id}
      all_conditions = conditions.join(' AND ')
      @goal = ArtistGoal.where(all_conditions, arguments).first
      @rewards =@goal.blank? ? [] : @goal.rewards.where(:trashed=>0)
      @return_goal= @goal.as_json
      @return_goal["rewards"] = @rewards.as_json if !@goal.blank?
      status 200
      @return_goal.blank? ? {} : @return_goal
    end

    desc "Get Supports for an Artist", {
      :params =>
      {
        "id" => { :desc => "User Identifier", :type => "long" },
      }
    }
    get ":id/supporters" do
      # user = User.find_by_id(params[:id].to_i)
      # goal= user.artist_goal
      # @supporters={}
      # if !goal.blank? then
      #   @supporters[:total_supporters]= user.number_of_supporters
      #   @supporters[:goal_amount]= goal.blank? ?  0 : goal.goal_amount
      #   @supporters[:raised_amount]= goal.blank? ?  0 : goal.raised_amount
      #   rewards = goal.rewards.where(:trashed=>0)
      #   @supporters[:rewards] = rewards.as_json
      # end
      supporters_hash={}
      artist = VwArtist.find_by_id(params[:id].to_i)
      supporters_hash[:phase_id]= artist.phase_id
      stats = artist.stats
      supporters_hash[:artist_stats] = stats
      login_id = params[:login_id].to_i

      supporting_crowd_details = artist.supporting_crowd_details
      crowd_level_hash={}

      role_chosen = artist.crowd_role_chosen
      role_chosen = "" if role_chosen.blank?
      chosen_levels = role_chosen.split(",").sort

      chosen_levels.each do |level|
        crowd_level_hash[level.to_i] = {}
        crowd_level_hash[level.to_i][:crowds]=[]
        crowd_level_hash[level.to_i][:count]=0
      end

      supporting_crowd_details.each do |sc|
        if crowd_level_hash[sc.support_level].blank? then
          crowd_level_hash[sc.support_level]={}
          crowd_level_hash[sc.support_level][:count]=0
          crowd_level_hash[sc.support_level][:crowds]=[]
          #crowd_level_hash[sc.support_level][:crowds]=[{:crowd_id=> sc.crowd_id,:crowd_first_name=>sc.crowd_first_name,:crowd_last_name=>sc.crowd_last_name,:crowd_avatar=>sc.crowd_avatar}]
        else
          crowd_level_hash[sc.support_level][:count] = crowd_level_hash[sc.support_level][:count]+1
          crowd_level_hash[sc.support_level][:crowds] << {:crowd_id=> sc.crowd_id,:crowd_first_name=>sc.crowd_first_name,:crowd_last_name=>sc.crowd_last_name,:crowd_avatar=>sc.crowd_avatar}
        end
      end

      crowd_level_hash.each do |k,v|
        crowd_level_hash[k][:crowds] = v[:crowds].shuffle.slice(0..4)
      end

      supporters_hash[:crowd_supporters]=crowd_level_hash
      crowd_role_chosen =   artist.crowd_role_chosen
      crowd_role_chosen= "" if crowd_role_chosen.blank?
      roles_chosen= crowd_role_chosen.split(',').map { |x| x.to_i }
      levels= CrowdDoerLevel.where(:id=>roles_chosen)  # for chosen levels
      levels_hash={}
      levels.each do |l|
        levels_hash[l.id]=l
      end

      supporters_hash[:support_levels]=levels_hash.as_json

      if (!login_id.blank?  && login_id > 0) then
        crowd_activity = VwCrowdActivity.where(:from_user_id=> login_id, :for_user_id=> params[:id].to_i)
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
      supporters_hash[:crowd_stats]=crowd_stats

      logger.debug supporters_hash
      status 200
      supporters_hash.as_json
    end


    desc "Get Supporter Levelsfor an Artist", {
      :params =>
      {
        "id" => { :desc => "User Identifier", :type => "long" },
      }
    }
    get ":id/supporter_levels" do
      artist= VwArtist.find_by_id(params[:id].to_i)
      crowd_levels=artist.supporter_levels
      respons_hash= {:crowd_levels=>crowd_levels,:stats=>artist.stats}

      status 200
      respons_hash.as_json
    end


    put ":user_id/supporter_levels" do
      all_levels = CrowdDoerLevel.where(:trashed=>0).pluck(:id)
      user = User.find(params[:user_id].to_i)
      chosen_levels = params[:selected_levels]
      arr_chosen_levles=[]
      chosen_levels.each do |k,v|
        arr_chosen_levles << k.to_i if v
      end
      raise_rest_error_with_status(423,"chosen set of crowd levels are Invalid") if !(arr_chosen_levles-all_levels).blank?
      chosen_levels_str= arr_chosen_levles.join(',')
      attr_param = {:crowd_role_chosen => chosen_levels_str}
      raise_rest_error user.errors.full_messages if !user.update_attributes(attr_param)
      ## updating crowd doers levels
      supporting_crowd_arr = ArtistCrowdSupportLevel.where(:artist_id=>params[:user_id].to_i,:trashed=>0).pluck(:crowd_id)
      CrowdDoerLevelUpdater.perfrom_async(supporting_crowd_arr, params[:user_id].to_i) if !supporting_crowd_arr.blank?

      status 200
      {}
    end

    put ":user_id/goals/:artist_goal_id" do
      @goal= ArtistGoal.where(:id=>params[:artist_goal_id].to_i,:user_id=>params[:user_id].to_i).first
      raise_rest_error_with_status(404, " No Goals found for User  ID #{params[:user_id]} and Goal id #{params[:artist_goal_id]}") if @goal.blank?

      logger.debug params.inspect

      @goal.attributes = params.select{|key, value|
        ArtistGoal.persist_fields.include?(key)
      }

      params.rewards.each do |reward|
        @goal.rewards << (Reward.new filter_params(reward,Reward.persist_fields))
      end

      raise_rest_error(@goal.errors.full_messages) if !@goal.save
      status 200
      @goal
    end

  end
end
