class Preauthorise
  def initialize(user)
    @user = user
  end

  def call
    tva_connection.post do |req|
      req.url '/permissions'
      req.headers['Authorization'] = "Token token=#{ENV['TVA_TOKEN']}"
      req.headers['Content-Type'] = 'application/json'
      req.body = JSON.generate(
        user_token: @user[:email],
        school_urn: @user[:school_urn]
      )
    end
  end

  private def tva_connection
    Faraday.new(ENV['TVA_URL'])
  end
end
