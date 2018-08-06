class CreateDfeSignInUser
  class InvitationFailed < RuntimeError; end

  def initialize(user)
    @user = user
  end

  def call
    sign_in_response = sign_in_connection.post do |req|
      req.url "/services/#{ENV['DFE_SIGN_IN_SERVICE_ID']}/invitations"
      req.headers['Authorization'] = "bearer #{generate_jwt_token}"
      req.headers['Content-Type'] = 'application/json'
      req.body = JSON.generate(sign_in_params)
    end
    if sign_in_response.success?
      Logger.new($stdout).info("Created invitation for #{@user[:email]} for #{@user[:schools].map {|school| school[:school_urn] }}")
      return true
    end
    raise InvitationFailed, sign_in_response.body
  end

  private def sign_in_connection
    Faraday.new(ENV['DFE_SIGN_IN_API_URL'])
  end

  private def generate_jwt_token
    payload = {
      iss: 'schooljobs',
      exp: (Time.now.getlocal + 60).to_i,
      aud: 'signin.education.gov.uk'
    }
    JWT.encode payload, ENV['DFE_SIGN_IN_API_PASSWORD'], 'HS256'
  end

  def sign_in_params
    {
      sourceId: :user_id_in_your_service,
      given_name: @user[:given_name],
      family_name: @user[:family_name],
      email: @user[:email],
      userRedirect: ENV['TEACHING_JOBS_SIGN_IN_URL']
    }
  end
end
