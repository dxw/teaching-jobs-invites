require 'faraday'
require 'notifications/client'
require 'pry'
require 'logger'
require 'csv'

Dir["./services/*.rb"].each {|file| require file }

class InviteToTeachingJobs
  class InvitationFailed < RuntimeError; end

  def self.run!
    users = []
    options = { encoding: 'UTF-8', skip_blanks: true, headers: true }
    CSV.foreach(user_data_file_name, options) do |row|
      users << row.to_h.transform_keys!(&:to_sym)
    end

    users.map do |user|
      Authorisation.new(user).preauthorise
    end

    unique_users = CsvRowsToUser.new(users).transform
    unique_users.map do |user|
      SendEmail.new(user).call
    end

    users.map do |user|
      CreateDfeSignInUser.new(user).call
    end

  rescue InvitationFailed => e
    log_error(e.message)
  end

  def self.user_data_file_name
    'users.csv'
  end

  private def log_error(response_body)
    $logger.warn("Error creating invitation for #{@user[:email]}. Response: #{response_body}")
  end
end
