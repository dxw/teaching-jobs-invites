class Authorisation
  class InvitationFailed < RuntimeError; end

  def initialize(user)
    @user = user
  end

  def preauthorise
    @user[:schools].each do |school|
      tva_response = tva_connection.post do |req|
        req.url '/permissions'
        req.headers['Authorization'] = "Token token=#{ENV['TVA_TOKEN']}"
        req.headers['Content-Type'] = 'application/json'
        req.body = JSON.generate(
          user_token: @user[:email],
          school_urn: school[:school_urn]
        )
      end
      raise InvitationFailed, tva_response.body unless tva_response.success?
    end
  end

  private def tva_connection
    Faraday.new(ENV['TVA_URL'])
  end
end
