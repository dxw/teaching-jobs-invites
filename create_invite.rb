require 'faraday'
require 'notifications/client'
require './preauthorise'
require './send_email'
require './create_dfe_sign_in_user'

class CreateInvite
  class InvitationFailed < RuntimeError; end

  def initialize(user:)
    @user = user
  end

  def call
    begin
      tva_response = Preauthorise.new(@user).call
      unless tva_response.success?
        raise InvitationFailed, tva_response.body
      end
      SendEmail.new(@user).call
      CreateDfeSignInUser.new(@user).call

    rescue InvitationFailed => e
      log_error(e.message)
    end
  end

  private

  def log_error(response_body)
    puts "Error creating invitation for #{@user[:email]}. Response: #{response_body}"
  end
end
