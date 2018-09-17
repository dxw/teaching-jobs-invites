require 'faraday'
require 'notifications/client'
require 'pry'
require 'logger'
require 'csv'

Dir["./services/*.rb"].each {|file| require file }

class InvitationFailed < RuntimeError; end
class InviteToTeachingJobs

  def self.run!
    InviteToTeachingJobs.new.run
  end

  def run
    users = []
    options = { encoding: 'UTF-8', skip_blanks: true, headers: true }
    CSV.foreach(user_data_file_name, options) do |row|
      users << row.to_h.transform_keys!(&:to_sym)
    end
    unique_school_count = users.group_by{|r| r[:school_urn] }.count

    users.map do |user|
      Authorisation.new(user).preauthorise
    end

    unique_users = CsvRowsToUser.new(users).transform
    unique_users.map do |user|
      SendEmail.new(user).call
    end

    organisation_finder = OrganisationFinder.new
    users.map do |user|
      CreateDfeSignInUser.new(user: user, organisation_finder: organisation_finder).call
    end

    logger.info "#{users.count} user accounts have been associated with #{unique_school_count} schools."
    logger.info "#{unique_users.count} emails were sent."
  rescue ::InvitationFailed => e
    log_error(e.message)
  end

  def user_data_file_name
    'users.csv'
  end

  private

  def log_error(response_body)
    logger.warn("Error creating invitation. Response: #{response_body}")
  end

  def logger
    @logger ||= Logger.new($stdout)
  end
end
