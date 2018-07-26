require 'faraday'
require 'notifications/client'

class CreateInvite
  class InvitationFailed < RuntimeError; end

  def initialize(user:, jwt_token:)
    @user = user
    @jwt_token = jwt_token
    @sign_in_connection = Faraday.new(ENV['DFE_SIGN_IN_API_URL'])
    @notify_client = Notifications::Client.new(ENV['NOTIFY_KEY'])
  end

  def call
    begin
      tva_response = Preauthorise.new(@user).call
      unless tva_response.success?
        raise InvitationFailed, tva_response.body
      end
      @notify_client.send_email(
        email_address: @user[:email],
        template_id: ENV['NOTIFY_TEMPLATE_ID'],
        personalisation: {
          first_name: @user[:given_name],
          school_name: @user[:school]
        },
        reference: "your_reference_string"
      )
      sign_in_response = @sign_in_connection.post do |req|
        req.url "/services/#{ENV['DFE_SIGN_IN_SERVICE_ID']}/invitations"
        req.headers['Authorization'] = "bearer #{@jwt_token}"
        req.headers['Content-Type'] = 'application/json'
        req.body = JSON.generate(sign_in_params)
      end
      if sign_in_response.success?
        puts "Created invitation for #{@user[:email]}"
        return true
      end
      raise InvitationFailed, sign_in_response.body

    rescue InvitationFailed => e
      log_error(e.message)
    end
  end

  private

  def log_error(response_body)
    puts "Error creating invitation for #{@user[:email]}. Response: #{response_body}"
  end

  def sign_in_params
    {
      sourceId: :user_id_in_your_service,
      given_name: @user[:given_name],
      family_name: @user[:family_name],
      email: @user[:email],
      userRedirect: ENV['TEACHING_JOBS_SIGN_IN_URL']
    }
  end
end
