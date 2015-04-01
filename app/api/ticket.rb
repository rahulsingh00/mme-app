require 'api_extension'
require 'api_decorator'

class Ticket < Grape::API

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
    desc "Create Ticket Record"
    post ":id/:event_id/bookings" do

      ticket_params = filter_params(params,Ticket.persist_fields)
      #ticket_params["opentok_role"]=OpenTok::RoleConstants::SUBSCRIBER if ticket_params["opentok_role"].blank?
      logger.debug ticket_params
      errors = nil

      Ticket.transaction do
        @ticket = Ticket.new ticket_params
        @ticket.event_id=params[:event_id]
        @ticket.user_id=params[:id]
        @event = Event.find(params[:event_id])
        @ticket.selling_price=@event.price_per_seat

        ### Payment Transaction has to fit in here

        ##############################################
        @ticket.status="booked"

        raise_rest_error_with_status(423,@ticket.errors.messages) if !@ticket.save
      end
      #send email to the user about the ticket details
      Pony.mail(:to => @ticket.user.email, :subject => "Ticket for event #{@ticket.event.title} ", :body => "Ticket code : #{@ticket.ticket_token} or use the URL http://mme-int.liftoffllc.in/hangout/#{params[:event_id]}/#{@ticket.ticket_token}")

      status 201
      @ticket
    end



    desc "autheticate ticket", {
      :params =>
      {
        "token" => { :desc => "Ticket Token", :type => "string" },
        "event" => { :desc => "event id ", :type => "long" }
      }
    }

    get ":token/:event/autheticate" do
      conditions, arguments = ["ticket_token = :token","status = :booking_status","event_id = :event_id"], {:token => params[:token].to_s.upcase, :booking_status => "booked" , :event_id=>params[:event].to_i}
      all_conditions = conditions.join(' AND ')

      ticket = Ticket.all(:conditions => [all_conditions, arguments])
      raise_rest_error_with_status(423,"Ticket is not valid for this event") if ticket.blank?
      status 200
      ticket[0]
    end

  end
end
