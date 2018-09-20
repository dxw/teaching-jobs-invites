require_relative 'api'

module DSI
  class Organisations < API
    attr_reader :school_urn

    def initialize(school_urn:)
      @school_urn = school_urn
    end

    def find
      response = connection.get("/organisations/find-by-type/001/#{school_urn}")
      return JSON.parse(response.body)['id'] if response.success?

      Logger.new($stdout).info("Unable to find a DSI Organisation associated with school urn #{school_urn}")
    end
  end
end
