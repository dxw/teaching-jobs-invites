require 'faraday'
require 'notifications/client'
require 'pry'
require 'logger'

Dir["./services/*.rb"].each {|file| require file }

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
    $logger.warn("Error creating invitation for #{@user[:email]}. Response: #{response_body}")
  end
end
