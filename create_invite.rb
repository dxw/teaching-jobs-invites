require 'faraday'
require 'notifications/client'
require './authorisation'
require './send_email'
require './create_dfe_sign_in_user'
require 'pry'

class CreateInvite
  class InvitationFailed < RuntimeError; end

  def initialize(user:)
    @user = user
  end

  def call
    Authorisation.new(@user).preauthorise
    SendEmail.new(@user).call
    CreateDfeSignInUser.new(@user).call
  rescue InvitationFailed => e
    log_error(e.message)
  end

  private

  def log_error(response_body)
    puts "Error creating invitation for #{@user[:email]}. Response: #{response_body}"
  end
end
