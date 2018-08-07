require 'logger'
require 'pry'
require 'csv'

class OrganisationFinder
  def self.call(school_urn:)
    organisation_id = organisations[school_urn]

    if organisation_id.nil?
      Logger.new($stdout)
            .warn("No organisation could be attached for #{school_urn}, add manually.")
    end

    organisation_id
  end

  def self.organisation_file_name
    ENV['ENVIRONMENT'].eql?('test') ? 'dsi-test-organisations.csv' : 'dsi-prod-organisations.csv'
  end

  def self.organisations
    organisations = {}
    options = { encoding: 'UTF-8', skip_blanks: true, headers: true }

    CSV.foreach(organisation_file_name, options) do |row|
      organisations.merge!({ row['school_urn'] => row['organisation_id'] })
    end

    organisations
  end
end
