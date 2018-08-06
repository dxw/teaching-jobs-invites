require 'logger'
require 'pry'

class OrganisationFinder
  def self.call(school_urn:)
    organisation_id = LOOKUP_TABLE[school_urn]

    if organisation_id.nil?
      Logger.new($stdout)
            .warn("No organisation could be attached for #{school_urn}, add manually.")
    end

    organisation_id
  end

  LOOKUP_TABLE = {
    '137138' => 'daf3ea45-2eaf-484b-9975-f2ef0af7eb37'
  }.freeze
end
