class CreateDfeSignInUser
  attr_reader :email, :given_name, :family_name, :school_urn, :organisation_finder

  def initialize(user:, organisation_finder:)
    @email = user[:email].strip
    @given_name = user[:given_name].strip
    @family_name = user[:family_name].strip
    @school_urn = user[:school_urn].strip
    @organisation_finder = organisation_finder
  end

  def call
    sign_in_response = sign_in_connection.post do |req|
      req.url "/services/#{ENV['DFE_SIGN_IN_SERVICE_ID']}/invitations"
      req.headers['Authorization'] = "bearer #{generate_jwt_token}"
      req.headers['Content-Type'] = 'application/json'
      req.body = JSON.generate(sign_in_params)
    end
    if sign_in_response.success?
      Logger.new($stdout).info("Created DfE Sign-in invitation for #{email} for #{school_urn}")
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
      given_name: given_name,
      family_name: family_name,
      email: email,
      userRedirect: ENV['TEACHING_JOBS_SIGN_IN_URL'],
      organisation: organisation_finder.call(school_urn: school_urn),
      inviteSubjectOverride: email_subject,
      inviteBodyOverride: email_copy
    }
  end

  private

  def email_subject
    "You’ve been invited to join DfE Sign-in by Teaching Jobs"
  end

  def email_copy
    "Teaching Jobs is a free online service for schools in England to list their teaching roles. To use it, schools must first register with DfE Sign-in. Save the following link, which you’ll use to securely access the service once you’ve registered: https://www.gov.uk/guidance/list-a-teaching-role-at-your-school-on-teaching-jobs"
  end
end
