require 'logger'
require 'pry'
require 'csv'

class OrganisationFinder
  def initialize
    load_organisations
  end

  def call(school_urn:)
    organisation_id = organisations[school_urn]

    if organisation_id.nil?
      Logger.new($stdout)
            .warn("No organisation could be attached for #{school_urn}, add manually.")
    end

    organisation_id
  end

  def organisation_file_name
    ENV['ENVIRONMENT'].eql?('test') ? 'dsi-test-organisations.csv' : 'dsi-prod-organisations.csv'
  end

  private def load_organisations
    organisations
  end

  private def organisations
    @organisations ||= begin
      organisations = {}
      options = { encoding: 'UTF-8', skip_blanks: true, headers: true }

      CSV.foreach(organisation_file_name, options) do |row|
        organisations.merge!({ row['school_urn'] => row['organisation_id'] })
      end

      organisations
    end
  end
  alias_method :all, :organisations
end
