require 'dotenv/load'
require 'jwt'
require 'faraday'
require 'logger'

module DSI
  class API
    private

    def connection
      @connection ||= Faraday.new(ENV['DFE_SIGN_IN_API_URL'], headers: headers)
    end

    def headers
      @headers ||= {
        'Authorization': "bearer #{generate_jwt_token}",
        'Content-Type': 'application/json'
      }
    end

    def generate_jwt_token
      payload = {
        iss: 'schooljobs',
        exp: (Time.now.getlocal + 60).to_i,
        aud: 'signin.education.gov.uk'
      }
      JWT.encode payload, ENV['DFE_SIGN_IN_API_PASSWORD'], 'HS256'
    end
  end
end
