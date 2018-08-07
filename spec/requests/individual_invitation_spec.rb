Dir['./services/*.rb'].each {|file| require file }

RSpec.describe 'Individual invitation' do
  before(:each) do
    ENV['TVA_URL'] = 'https://www.example.com'
    ENV['NOTIFY_KEY'] = 'abc'
    ENV['NOTIFY_WELCOME_TEMPLATE_ID'] = '123'
    ENV['DFE_SIGN_IN_API_PASSWORD'] = '456'
    ENV['DFE_SIGN_IN_API_URL'] = 'https://sign-in.com'
    ENV['DFE_SIGN_IN_SERVICE_ID'] = '123456789'
    ENV['TEACHING_JOBS_SIGN_IN_URL'] = '/callback'
    ENV['ENVIRONMENT'] = 'test'
  end

  after(:each) do
    ENV.delete('TVA_URL')
    ENV.delete('NOTIFY_KEY')
    ENV.delete('NOTIFY_WELCOME_TEMPLATE_ID')
    ENV.delete('DFE_SIGN_IN_API_PASSWORD')
    ENV.delete('DFE_SIGN_IN_API_URL')
    ENV.delete('DFE_SIGN_IN_SERVICE_ID')
    ENV.delete('TEACHING_JOBS_SIGN_IN_URL')
    ENV.delete('ENVIRONMENT')
  end

  it 'invites the user' do
    allow(InviteToTeachingJobs).to receive(:user_data_file_name)
      .and_return('./spec/fixtures/individual_test_users.csv')

    allow(OrganisationFinder).to receive(:organisation_file_name)
      .and_return('./spec/fixtures/dsi-test-organisations.csv')

    user = {
      email: 'test@digital.education.gov.uk',
      given_name: 'Test',
      family_name: 'Tester',
      school_name: 'Crown Wood Primary School',
      school_urn: '144048'
    }

    authorisation_body = JSON.generate(user_token: user[:email], school_urn: user[:school_urn])
    authorisation_stub = WebMock.stub_request(:post, 'https://www.example.com/permissions')
                                .with(body: authorisation_body)
                                .to_return(
                                  status: 200,
                                  body: '{"id":83,"user_token":"test@digital.education.gov.uk","school_urn":"144048","created_at":"2018-07-27T08:54:49.673Z"}'
                                )

    notify_client = instance_double(Notifications::Client)
    allow(Notifications::Client).to receive(:new).and_return(notify_client)
    expect(notify_client)
      .to receive(:send_email)
      .with(
        email_address: user[:email],
        template_id: ENV['NOTIFY_WELCOME_TEMPLATE_ID'],
        personalisation: {
          first_name: user[:given_name],
          family_name: user[:family_name],
          school_name: user[:school_name],
        },
        reference: 'welcome-to-teaching-jobs-email'
      )

    sign_in_payload = JSON.generate(sourceId: 'user_id_in_your_service',
                                    given_name: user[:given_name],
                                    family_name: user[:family_name],
                                    email: user[:email],
                                    userRedirect: '/callback',
                                    organisation: '7FE7B046-3016-4339-A6C7-00267187C523'
                                  )
    sign_in_stub = WebMock.stub_request(:post, 'https://sign-in.com/services/123456789/invitations')
                          .with(body: sign_in_payload)
                          .to_return(status: 200, body: '', headers: {})

    mock_logger = instance_double(Logger)
    allow(Logger).to receive(:new).and_return(mock_logger)
    expect(mock_logger).to receive(:info)
      .with('Created DfE Sign-in invitation for test@digital.education.gov.uk for 144048')

    InviteToTeachingJobs.run!

    WebMock.assert_requested(authorisation_stub)
    WebMock.assert_requested(sign_in_stub)
  end
end
