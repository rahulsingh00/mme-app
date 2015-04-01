require 'api_extension'
require 'api_decorator'

class Event < Grape::API

  helpers RestHelpers
  # use ApiDecorator

  #version 'v1', :using => :header, :vendor => 'mme', :format => :json, :strict => true
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

  resource 'events' do
    desc "Get event object based on Ids", {
      :params =>
      {
        "ids" => { :desc => "Event Identifier(s)", :type => "long" },
        "result_size" => { :desc => "Result Size; Default - 20", :type => "long" },
        "last_id" => { :desc => "Last Seen Id", :type => "long" },
        " event_month" => { :desc => "month of the event", :type=> "string"}
      }
    }


    get "/live_events/:event_month" do
      event_ids = parse_csv_as_int_array(params[:ids])
      result_size = parse_or_default_to(params[:result_size], 20).to_i
      last_id = parse_or_default_to(params[:last_id], 0).to_i
      event_month= parse_or_default_to(params[:event_month],Time.now.to_s[0..6]).to_s

      if event_ids.blank?
        # TODO: In case of all events; order should be by rank desc.
        conditions, arguments = [], {}
        if last_id != 0
          conditions << 'id < :event_id'
          arguments[:event_id] = last_id
        end

        if !event_month.blank? then
          conditions << 'EXTRACT(MONTH from start_time) = :event_month' << 'EXTRACT(YEAR from start_time) = :event_year'
          arguments[:event_year]= event_month.strip.split('-').first
          arguments[:event_month]= event_month.strip.split('-').second
        end

        #conditions << 'trashed = 0'
        all_conditions = conditions.join(' AND ')

        event_list = VwEvent.where(all_conditions, arguments).order('start_time')
        #:limit => result_size,
      else
        event_hash = VwEvent.find_all_by_id(event_ids).index_by(&:id)
        # maintaining the order
        event_list = event_ids.collect{|id| event_hash[id]}.flatten.compact
      end

      status 200
      event_list
    end


    desc "Get hangout messages", {
      :params =>
      {
        "result_size" => { :desc => "Result Size; Default - 30", :type => "long" },
        "event_id" => { :desc => "event id;",:type => "long" }
      }
    }

    get "/:event_id/messages" do

      result_size = parse_or_default_to(params[:result_size], 30).to_i
      conditions, arguments = [], {}
      conditions << 'event_id = :event_id' << 'trashed = 0'
      arguments[:event_id] = params[:event_id].to_i

      all_conditions = conditions.join(' AND ')

      message_list = HangoutMessage.all(
      :conditions => [all_conditions, arguments],
      :limit => result_size,
      :order => "created_at"
      )
      status 200
      message_list
    end

  end


  resource 'users' do

    desc "Create Event Record"
    post ":id/events" do

      logger.info params.inspect
      event_params = filter_params(params,Event.persist_fields)
      opentok_session_id = OTSDK.createSession().to_s

      logger.debug "event params "
      logger.debug event_params.inspect

      @event = Event.new event_params
      @event.opentok_session_id = opentok_session_id
      logger.info @event.inspect


      ticket_params= {:user_id=>params[:id],:selling_price=>0,:status=>'booked',:opentok_role=>OpenTok::RoleConstants::PUBLISHER,:user_role=>'artist'}
      @ticket = Ticket.new ticket_params

      Event.transaction do
        raise_rest_error_with_status(423,@event.errors.full_messages) if !@event.save!
        @ticket.event_id=@event.id
        raise_rest_error_with_status(423,@ticket.errors.full_messages) if !@ticket.save!
      end
      status 201
      @event
    end


    desc "update event details"
    put":id/events" do
      @event = Event.find_by_id(params[:id])
      raise_rest_error "Event Not Found" if @event.blank?

      Event.transaction do
        @event.attributes = params.select{|key, value|
          Event.persist_fields.include?(key)
        }
        raise_rest_error(@event.errors.full_messages) if !@event.save
      end
      status 200
      @event
    end


    desc "Get Events for User", {
      :params =>
      {
        "id" => { :desc => "User Identifier", :type => "long" }
      }
    }
    # get ":id/events" do
    #   user_id = params[:id].to_i


    #   conditions, arguments = ["user_id = :user_id","trashed =0"], {:user_id => user_id}
    #   all_conditions = conditions.join(' AND ')

    #   events_list = Event.all(:conditions => [all_conditions, arguments],  :order => "CREATED_AT DESC")
    #   {:events => events_list}
    # end

    ##################### get from event_view #####################
    get ":id/events" do
      user_id = params[:id].to_i


      conditions, arguments = ["user_id = :user_id"], {:user_id => user_id}
      all_conditions = conditions.join(' AND ')

      events_list = VwEvent.where(all_conditions, arguments).order("start_time")
      {:events => events_list}
    end


    desc "Get booked Events for User", {
      :params =>
      {
        "id" => { :desc => "User Identifier", :type => "long" }
      }
    }

    get ":id/booked_events" do
      user_id = params[:id].to_i
      conditions, arguments = ["user_id = :user_id"], {:user_id => user_id}
      all_conditions = conditions.join(' AND ')

      events_booked=VwBookedEvent.all(:conditions => [all_conditions, arguments],  :order => "start_time")
      #events_booked=VwBookedEvent.find_by_user_id(user_id)

      status 200
      events_booked
    end


    desc "upload media during hangout"
    post ":user_id/events/:event_id/hangout_messages" do
      logger.info params.inspect

      hangout_message_params = filter_params(params,HangoutMessage.persist_fields)
      ChatMessageDBPusher.perform_async(hangout_message_params)

      status 201
      hangout_message_params
    end

    desc "join the event"
    get ":user_id/events/:event_id/join/:ticket_token" do

      logger.info params.inspect
      ################################################
      # If the user is logged in then check for the valid opentok token for the event and let him join if eligible
      ################################################

      @event=Event.where(:id=>params[:event_id].to_i,:trashed=>0).first
      raise_rest_error ("There is no valid event with id #{params[:event_id]}") if @event.blank?
      if @event.user_id == params[:user_id].to_i then #for artist to join the event as publisher
        #@opentok_detail = @event.opentok_details.first
        raise_rest_error(" There are no sessions created for event#{params[:event_id]}") if @event.opentok_session_id.blank?

        @ticket = Ticket.where(:user_role=>"artist",:event_id=>params[:event_id],:ticket_token=>params[:ticket_token],:status=>['booked','viewing']).first

        raise_rest_error ("Invalid ticket code to join the event as an artist") if @ticket.blank?

        if @ticket.status=='viewing' then
          raise_rest_error("Ticket is used by some other user.Please use another ticket") if @ticket.used_by_user_id.to_i != params[:user_id].to_i
          @opentok_detail= OpentokDetail.where(:ticket_code=>@ticket.ticket_token).first
        else
          opentok_role=@ticket.opentok_role.blank? ? OpenTok::RoleConstants::PUBLISHER : @ticket.opentok_role
          opetok_token=OTSDK.generateToken :session_id=>@event.opentok_session_id, :role=> opentok_role

          @opentok_detail=OpentokDetail.new :event_id=>params[:event_id].to_i, :user_id=>params[:user_id].to_i,:token=>opetok_token, :session_id=>@event.opentok_session_id,:ticket_code=>@ticket.ticket_token

          Ticket.transaction do
            ticket_update_param={:status=>"viewing",:used_by_user_id=>params[:user_id]}
            raise_rest_error(@ticket.errors.full_messages) if !@ticket.update_attributes(ticket_update_param)
            raise_rest_error(@opentok_detail.errors.full_messages) if !@opentok_detail.save
          end
        end

      else # for crowd user to join event
        @ticket=Ticket.where(:ticket_token=>params[:ticket_token],:user_role=>"crowd",:event_id=>params[:event_id].to_i,:status=>["viewing","booked"]).first
        raise_rest_error ("Ticket is not valid for the event") if @ticket.blank?

        if !@ticket.used_by_user_id.blank? && @ticket.used_by_user_id!=params[:user_id].to_i then
          raise_rest_error("This Ticket is being used by some other user.Please use some other ticket")
        end

        if @ticket.status == "viewing" then
          @opentok_detail= OpentokDetail.where(:ticket_code=>@ticket.ticket_token).first
        else
          @ticket.status="viewing"
          @ticket.used_by_user_id=params[:user_id].to_i

          opentok_role=@ticket.opentok_role.blank? ? OpenTok::RoleConstants::SUBSCRIBER : @ticket.opentok_role
          opetok_token=OTSDK.generateToken :session_id=>@event.opentok_session_id, :role=> opentok_role

          @opentok_detail= OpentokDetail.new :event_id=>params[:event_id].to_i, :user_id=>params[:user_id].to_i,:token=>opetok_token, :session_id=>@event.opentok_session_id,:ticket_code=>@ticket.ticket_token

          Ticket.transaction do
            ticket_update_param={:status=>"viewing",:used_by_user_id=>params[:user_id]}
            raise_rest_error(@ticket.errors.full_messages) if !@ticket.update_attributes(ticket_update_param)
            raise_rest_error(@opentok_detail.errors.full_messages) if !@opentok_detail.save
          end
        end

      end

      raise_rest_error("Opentok Token Expired ..") if ( !@opentok_detail.token_expires_at.blank? && (@opentok_detail.token_expires_at < Time.now ))
      status 200
      @opentok_detail
    end

    desc "Delete Events Ids", {
      :params =>
      {
        "event_ids" => { :desc => "Event Identifier(s)", :type => "long" }
      }
    }
    delete ":id/events/:event_ids" do
      event_ids = parse_csv_as_int_array(params[:event_ids])
      raise_rest_error_with_status(423,"No Event Found with the id") if event_ids.blank?

      criteria = {:user_id => params[:id] ,:trashed => 0}
      criteria.merge!(:id => event_ids) unless event_ids.blank?

      Event.update_all({:trashed => 1}, criteria)
      status 200
      {}
    end

  end
end
