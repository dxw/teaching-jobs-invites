require_relative 'api'
require_relative 'organisations'

module DSI
  class Invitations < API
    attr_reader :email, :given_name, :family_name, :school_urn, :organisation_id

    def initialize(user:, organisation_id:)
      @email = user[:email].strip
      @given_name = user[:given_name].strip
      @family_name = user[:family_name].strip
      @school_urn = user[:school_urn].strip
      @organisation_id = organisation_id
    end

    def call
      response = connection.post "/services/#{ENV['DFE_SIGN_IN_SERVICE_ID']}/invitations" do |req|
        req.body = JSON.generate(sign_in_params)
      end

      if response.success?
        Logger.new($stdout).info("Created DfE Sign-in invitation for #{email} for #{school_urn}")
        return true
      end

      raise DSI::InvitationFailed, response.body
    end

    private

    def sign_in_params
      {
        sourceId: :user_id_in_your_service,
        given_name: given_name,
        family_name: family_name,
        email: email,
        userRedirect: ENV['TEACHING_JOBS_SIGN_IN_URL'],
        organisation: organisation_id,
        inviteSubjectOverride: email_subject,
        inviteBodyOverride: email_copy
      }
    end

    def email_subject
      "You’ve been invited to join DfE Sign-in by Teaching Jobs"
    end

    def email_copy
      "Teaching Jobs is a free online service for schools in England to list their teaching roles. To use it, schools must first register with DfE Sign-in. Save the following link, which you’ll use to securely access the service once you’ve registered: https://www.gov.uk/guidance/list-a-teaching-role-at-your-school-on-teaching-jobs"
    end
  end

  class InvitationFailed < RuntimeError; end
end
