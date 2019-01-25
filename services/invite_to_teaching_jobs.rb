require 'faraday'
require 'notifications/client'
require 'pry'
require 'logger'

Dir["./services/**/*.rb"].each {|file| require file }

class InviteToTeachingJobs

  def self.run!
    InviteToTeachingJobs.new.run
  end

  def run
    @converted_csv = CsvRowsToUser.new(user_data_file_name)

    if @converted_csv.errors.count > 0
      log_parsing_errors
    else
      @users = @converted_csv.users
      unique_school_count = @users.group_by{|r| r[:school_urn] }.count

      preauthorise_users
      send_invitations
      setup_accounts

      logger.info "#{@users.count} user accounts have been associated with #{unique_school_count} schools."
      logger.info "#{@unique_users.count} emails were sent."
    end
  rescue AuthorisationFailed => e
    log_error("User authorisation in TVA failed: #{e.message}")
  rescue DSI::InvitationFailed => e
    log_error("DSI Invitation failed to be created: #{e.message}")
  rescue Notifications::Client::RequestError => e
    log_error("Notify email failed to sent: #{e.message}")
  end

  def user_data_file_name
    'users.csv'
  end

  def setup_accounts
    @users.map do |user|
      organisation_id = DSI::Organisations.new(school_urn: user[:school_urn]).find
      DSI::Invitations.new(user: user, organisation_id: organisation_id).call
    end
  end

  def send_invitations
    @unique_users = @converted_csv.unique_users
    @unique_users.map do |user|
      SendEmail.new(user).call
    end
  end

  def preauthorise_users
    @users.map do |user|
      Authorisation.new(user).preauthorise
    end
  end

  private

  def log_error(response_body)
    logger.warn("Error creating invitation. Response: #{response_body}")
  end

  def logger
    @logger ||= Logger.new($stdout)
  end

  def log_parsing_errors
    @converted_csv.errors.each do |error|
      logger.error(error)
    end
  end
end
