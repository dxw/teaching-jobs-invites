Dir['./services/*.rb'].each {|file| require file }

RSpec.describe 'Multiple invitations' do
  before(:each) do
    ENV['TVA_URL'] = 'https://www.example.com'
    ENV['NOTIFY_KEY'] = 'abc'
    ENV['NOTIFY_WELCOME_TEMPLATE_ID'] = '123'
    ENV['DFE_SIGN_IN_API_PASSWORD'] = '456'
    ENV['DFE_SIGN_IN_API_URL'] = 'https://sign-in.com'
    ENV['DFE_SIGN_IN_SERVICE_ID'] = '123456789'
    ENV['TEACHING_JOBS_SIGN_IN_URL'] = '/callback'
  end

  after(:each) do
    ENV.delete('TVA_URL')
    ENV.delete('NOTIFY_KEY')
    ENV.delete('NOTIFY_WELCOME_TEMPLATE_ID')
    ENV.delete('DFE_SIGN_IN_API_PASSWORD')
    ENV.delete('DFE_SIGN_IN_API_URL')
    ENV.delete('DFE_SIGN_IN_SERVICE_ID')
    ENV.delete('TEACHING_JOBS_SIGN_IN_URL')
  end

  context 'when the email address is the same' do
    it 'invites the user' do
      allow(InviteToTeachingJobs).to receive(:user_data_file_name)
        .and_return('./spec/fixtures/multiple_test_users.csv')

      allow_any_instance_of(OrganisationFinder).to receive(:organisation_file_name)
        .and_return('./spec/fixtures/dsi-test-organisations.csv')

      first_row = {
        email: 'test@digital.education.gov.uk',
        given_name: 'Test',
        family_name: 'Tester',
        school_name: 'St Christopher Primary School',
        school_urn: '103652'
      }

      first_authorisation_body = JSON.generate(user_token: first_row[:email], school_urn: first_row[:school_urn])
      first_authorisation_stub = WebMock.stub_request(:post, 'https://www.example.com/permissions')
                                   .with(body: first_authorisation_body)
                                   .to_return(
                                     status: 200,
                                     body: '{"id":83,"user_token":"test@digital.education.gov.uk","school_urn":"103652","created_at":"2018-07-27T08:54:49.673Z"}'
                                   )

      second_row = {
        email: 'test@digital.education.gov.uk',
        given_name: 'Test',
        family_name: 'Tester',
        school_name: 'Macmillan Academy',
        school_urn: '137138'
      }
      second_authorisation_body = JSON.generate(user_token: second_row[:email], school_urn: second_row[:school_urn])
      second_authorisation_stub = WebMock.stub_request(:post, 'https://www.example.com/permissions')
                                   .with(body: second_authorisation_body)
                                   .to_return(
                                     status: 200,
                                     body: '{"id":83,"user_token":"test@digital.education.gov.uk","school_urn":"137138","created_at":"2018-07-27T08:54:49.673Z"}'
                                  )

      notify_client = instance_double(Notifications::Client)
      allow(Notifications::Client).to receive(:new).and_return(notify_client)
      expect(notify_client)
        .to receive(:send_email)
        .with(
          email_address: first_row[:email],
          template_id: ENV['NOTIFY_WELCOME_TEMPLATE_ID'],
          personalisation: {
            first_name: first_row[:given_name],
            family_name: first_row[:family_name],
            school_name: '2 schools'
          },
          reference: 'welcome-to-teaching-jobs-email'
        ).once

      first_sign_in_payload = JSON.generate(sourceId: 'user_id_in_your_service',
                                     given_name: first_row[:given_name],
                                     family_name: first_row[:family_name],
                                     email: first_row[:email],
                                     userRedirect: '/callback',
                                     organisation: 'E552F3B4-4C1C-43B1-A2BC-000040C04C60'
                                   )
      first_sign_in_stub = WebMock.stub_request(:post, 'https://sign-in.com/services/123456789/invitations')
                                  .with(body: first_sign_in_payload)
                                  .to_return(status: 200, body: '', headers: {})

      second_sign_in_payload = JSON.generate(sourceId: 'user_id_in_your_service',
                                      given_name: first_row[:given_name],
                                      family_name: first_row[:family_name],
                                      email: first_row[:email],
                                      userRedirect: '/callback',
                                      organisation: '5BE7D1AE-D281-4DF1-8F93-0001BE69E525'
                                    )
      second_sign_in_stub = WebMock.stub_request(:post, 'https://sign-in.com/services/123456789/invitations')
                                   .with(body: second_sign_in_payload)
                                   .to_return(status: 200, body: '', headers: {})

      mock_logger = instance_double(Logger)
      allow(Logger).to receive(:new).and_return(mock_logger)
      expect(mock_logger).to receive(:info)
        .with('Preauthorised test@digital.education.gov.uk for 103652')
      expect(mock_logger).to receive(:info)
        .with('Preauthorised test@digital.education.gov.uk for 137138')
      expect(mock_logger).to receive(:info)
        .with('Sent welcome email to test@digital.education.gov.uk for 2 schools')
      expect(mock_logger).to receive(:info)
        .with('Created DfE Sign-in invitation for test@digital.education.gov.uk for 103652')
      expect(mock_logger).to receive(:info)
        .with('Created DfE Sign-in invitation for test@digital.education.gov.uk for 137138')

      InviteToTeachingJobs.run!

      WebMock.assert_requested(first_authorisation_stub)
      WebMock.assert_requested(second_authorisation_stub)
      WebMock.assert_requested(first_sign_in_stub)
      WebMock.assert_requested(second_sign_in_stub)
    end
  end
end
