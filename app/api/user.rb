require 'api_extension'
require 'api_decorator'

class User < Grape::API

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

    desc "Get User object based on Ids", {
      :params =>
      {
        "ids" => { :desc => "User Identifier(s)", :type => "long" },
        "result_size" => { :desc => "Result Size; Default - 20", :type => "long" },
        "last_id" => { :desc => "Last Seen Id", :type => "long" }
      }
    }
    ################This gets data from base tables ##########################
    # get do
    #   user_ids = parse_csv_as_int_array(params[:ids])
    #   result_size = parse_or_default_to(params[:result_size], 20).to_i
    #   last_id = parse_or_default_to(params[:last_id], 0).to_i

    #   if user_ids.blank?
    #     # TODO: In case of all users; order should be by rank desc.
    #     conditions, arguments = [], {}
    #     if last_id != 0
    #       conditions << 'id < :user_id'
    #       arguments[:user_id] = last_id
    #     end
    #     conditions << 'trashed = 0' << 'user_type > 0'
    #     all_conditions = conditions.join(' AND ')

    #     user_list = User.all(
    #     :conditions => [all_conditions, arguments],
    #     :limit => result_size,
    #     :order => "created_at DESC"
    #     )
    #   else
    #     user_hash = User.find_all_by_id(user_ids).index_by(&:id)
    #     # maintaining the order
    #     user_list = user_ids.collect{|id| user_hash[id]}.flatten.compact
    #   end
    #   status 200
    #   {:users => user_list}
    # end


    #################### This gets data from vw_artists#################
     get do
      user_ids = parse_csv_as_int_array(params[:ids])
      result_size = parse_or_default_to(params[:result_size], 20).to_i
      last_id = parse_or_default_to(params[:last_id], 0).to_i

      if user_ids.blank?
        # TODO: In case of all users; order should be by rank desc.
        conditions, arguments = [], {}
        if last_id != 0
          conditions << 'id < :user_id'
          arguments[:user_id] = last_id
        end
        conditions  << 'user_type > 0'
        all_conditions = conditions.join(' AND ')

        user_list = VwArtist.where(all_conditions, arguments).limit(result_size).order("created_at DESC")
      else
        user_hash = VwArtist.find_all_by_id(user_ids).index_by(&:id)
        # maintaining the order
        user_list = user_ids.collect{|id| user_hash[id]}.flatten.compact
      end
      status 200
      {:users => user_list}
    end



    desc "Create user"
    post do

      user_params = filter_params(params, User.persist_fields)
      logger.debug params

      user_params[:password] = "" if params[:password].blank?
      user_params[:password_confirmation]="" if params[:password_confirmation].blank?

      logger.debug user_params
      existing_user = {}
      user = User.new user_params
      logger.debug user.user_type
      #check whether the user is already present and return the user
      if !params[:access].blank? then
        conditions, arguments = [], {}
        conditions << 'network_id = :network_id' <<  'network_type = :network_type'
        arguments[:network_id] = params[:access]["network_id"]
        arguments[:network_type] = params[:access]["network_type"]
        all_conditions = conditions.join(' AND ')

        social_connect_rec= SocialConnect.all(
        :conditions => [all_conditions, arguments],
        :limit => 1
        )
        existing_user = social_connect_rec.blank? ? {} : social_connect_rec.first.user
      end


      logger.info existing_user.to_json
      if existing_user.blank? then

        if params[:address]
          address_params = filter_params(params[:address], Address.persist_fields)
          user.address = Address.new address_params
        elsif user.user_type.to_i != 0
          raise_rest_error "Address not specified"
        end

        logger.debug params[:access]
        if params[:access]
          access_params = filter_params(params[:access], SocialConnect.persist_fields)
          if access_params['network_type'].to_i == 1
            user.twitter_connect = SocialConnect.new access_params
          elsif access_params['network_type'].to_i == 2
            user.facebook_connect = SocialConnect.new access_params
          end
        else
          raise_rest_error "Network not specified"
        end

        phase_param=  {:phase =>1}
        phase_ledger=PhaseLedger.new phase_param
        user.phase_ledgers << phase_ledger

        raise_rest_error_with_status(423, user.errors.full_messages) if !user.save

        #A worker Thread to send email to new users
        #UserUpdater.perform_async(user.id)
        NewUserMailNotifier.perform_async(user.email)

        status 201
        user
      else
        logger.info "User with this social_connect is existing : #{params[:access]}"
        status 200
        existing_user
      end
    end

    desc "logging in the user"
    post "/authenticates" do
      params=JSON.parse(request.body.read.to_s)
      logger.debug params
      logger.debug "logging in the user #{params["email"]}"
      logger.debug params["password"]
      raise_rest_error_with_status(401,"Unauthorized user") if !user=User.find_by_email(params["email"]).try(:authenticate,params["password"])

      status 200
      user
    end

    desc "reset password" , {
      :params =>
      {
        "action" => { :desc => "reset action  type", :type => "string" }
      }
    }
    put ":action/reset" do
      #reset_params=JSON.parse(request.body.read.to_s)
      reset_params=params

      logger.debug reset_params
      if params["action"]=="reset"
        logger.debug "resetting the password "
        user=User.find_by_reset_password_token(reset_params["reset_password_token"])
        raise_rest_error "token not found"  if user.blank?
        if ((Time.now - user.password_reset_requested_at)/3600) > 2 then
          raise_rest_error "reset Token Expired"
        end
        password_update_param={}

        password_update_param["password"]= reset_params["password"].blank? ? "" : reset_params["password"]
        password_update_param["password_confirmation"]= reset_params["password_confirmation"].blank? ? "" : reset_params["password_confirmation"]
        password_update_param["reset_password_token"]=nil
        password_update_param["password_reset_requested_at"]=nil
        raise_rest_error user.errors.full_messages if !user.update_attributes(password_update_param)
        status 200
        user
      elsif  params["action"]=="initiate"

        logger.debug reset_params["email"]
        user=User.find_by_email(reset_params["email"])
        raise_rest_error "user not found for email #{reset_params["email"]}" if user.blank?
        user.reset_password_token=SecureRandom.base64.tr("+/", "-_")
        user.reset_password_token="" if user.reset_password_token.blank?
        user.password_reset_requested_at = Time.now
        user.password=""
        raise_rest_error user.errors.full_messages if !user.save

        Pony.mail(:to => user.email, :subject => 'MME Reset Password Link', :body => 'Hi .Please Click on the reset link to change your password, Within 2 Hrs of submitting you reset Request.')

        status 200
        {}

      end
    end


    desc "Update user"
    put ":id" do
      user = User.find_by_id(params[:id])
      raise_rest_error "User Not Found" if user.blank?

      if params[:address]
        address = user.address
        address.attributes = params[:address].select{|key, value|
          Address.persist_fields.include?(key)
        }
        raise_rest_error(address.errors.full_messages) if !address.save
      end

      logger.debug "============access paramters========="
      logger.debug params[:access]
      if params[:access]

        conditions, arguments = ["network_id = :network_id","network_type = :network_type"], {}

        #conditions << 'user_id = :id' << 'network_type = :network_type'
        arguments[:network_id] = params[:access][:network_id]
        arguments[:network_type]= params[:access][:network_type] if !params[:access][:network_type].blank?

        all_conditions = conditions.join(' AND ')
        user_list = SocialConnect.all(
        :conditions => [all_conditions, arguments],
        :limit => 1
        )

        if user_list.blank? then
          access_params = params[:access].select{|key, value|
            SocialConnect.persist_fields.include?(key)
          }

          if access_params['network_type'].to_i == 1
            social_connect = user.twitter_connect
          elsif access_params['network_type'].to_i == 2
            social_connect = user.facebook_connect
          end

          social_connect ||= SocialConnect.new :user_id => params[:id].to_i
          social_connect.attributes = access_params
          raise_rest_error(social_connect.errors.full_messages) if  !social_connect.save
        end
      end

      user.attributes = params.select{|key, value|
        User.persist_fields.include?(key)
      }
      raise_rest_error(user.errors.full_messages) if !user.save
      #UserUpdater.perform_async(user.id)
      status 200
      user
    end
  end
end
