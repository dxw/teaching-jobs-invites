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
    unique_school_count = users.group_by{|r| r[:school_urn] }.count

    users.map do |user|
      Authorisation.new(user).preauthorise
    end

    unique_users = converted_csv.unique_users
    unique_users.map do |user|
      SendEmail.new(user).call
    end

    users.map do |user|
      organisation_id = DSI::Organisations.new(school_urn: user[:school_urn]).find
      DSI::Invitations.new(user: user, organisation_id: organisation_id).call
    end

    logger.info "#{users.count} user accounts have been associated with #{unique_school_count} schools."
    logger.info "#{unique_users.count} emails were sent."
  rescue AuthorisationFailed => e
    log_error("User authorisation in TVA failed: #{e.message}")
  rescue DSI::InvitationFailed => e
    log_error("DSI Invitation failed to be created: #{e.message}")
  end

  def user_data_file_name
    'users.csv'
  end

  def converted_csv
    @converted_csv ||= CsvRowsToUser.new(user_data_file_name)
  end

  def users
    @user ||= converted_csv.users
  end

  private

  def log_error(response_body)
    logger.warn("Error creating invitation. Response: #{response_body}")
  end

  def logger
    @logger ||= Logger.new($stdout)
  end
end
