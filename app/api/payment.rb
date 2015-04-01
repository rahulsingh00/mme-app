require 'api_extension'
require 'api_decorator'

class Payment < Grape::API

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

    desc "Make payments"
    post '/:user_id/payments' do
      payment_params = filter_params(params,PaymentDetail.persist_fields)

      logger.debug payment_params

      user= User.find(params["user_id"].to_i)
      artist = User.find(payment_params["artist_id"])
      raise_rest_error_with_status(423, "user not found with id #{params[:user_id]}") if user.blank?
      raise_rest_error_with_status(423, "Stripe token can not be blank") if payment_params["stripe_token"].blank?
      raise_rest_error_with_status(423, "artist goal is not set") if (artist_goal= artist.artist_goal).blank?

      begin
        PaymentDetail.transaction do
          raise_rest_error_with_status(423,"stripe customer could not be created") if (customer = PaymentDetail.create_stripe_customer(payment_params["stripe_token"],user.email)).blank?
          payment_params["stripe_customer_id"] = customer.id
          @payment_detail= PaymentDetail.new payment_params
          raise_rest_error_with_status(423,@payment_detail.errors.full_messages) if !@payment_detail.save
          #raise_rest_error_with_status(423, "artist goal is not set") if (artist_goal= artist.artist_goal).blank?
          #artist_goal.raised_amount=artist_goal.raised_amount.to_f+payment_params["amount"].to_f
          #raise_rest_error_with_status(423, "raised amount for goal could not be updated") if !artist_goal.save
        end
      rescue Exception => e
        #raise_rest_error_with_status(423,e.message)
        raise_rest_error(e.message)
        #errors.full_messages
      end
      ## Re-calculate the crowd -Doer level
      CrowdDoerLevelUpdater.perform_async([params["user_id"].to_i] , payment_params["artist_id"].to_i)

      #A worker Thread to send email to new users
      PledgingMadeMailNotifier.perform_async(@payment_detail.user_id , @payment_detail.artist_id, @payment_detail.amount, @payment_detail.stripe_token )

      #charge the cards if the artist has reached his goal
      #PaymentRealizer.perform_async(payment_params["artist_id"].to_i)
      status 201
      @payment_detail

    end

  end
end
