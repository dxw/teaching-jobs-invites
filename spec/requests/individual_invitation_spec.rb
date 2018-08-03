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

  it 'invites the user' do
    user = {
      email: 'test@digital.education.gov.uk',
      given_name: 'Test',
      family_name: 'Tester',
      schools: [{school_name: 'Macmillan Academy', school_urn: '137138'}]
    }

    authorisation_body = JSON.generate(user_token: user[:email], school_urn: user[:schools].first[:school_urn])
    authorisation_stub = WebMock.stub_request(:post, 'https://www.example.com/permissions')
                                .with(body: authorisation_body)
                                .to_return(
                                  status: 200,
                                  body: '{"id":83,"user_token":"test@digital.education.gov.uk","school_urn":"137138","created_at":"2018-07-27T08:54:49.673Z"}'
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
          school_name: user[:schools].first[:school_name]
        },
        reference: 'welcome-to-teaching-jobs-email'
      )

    sign_in_payload = JSON.generate(sourceId: 'user_id_in_your_service',
                                    given_name: 'Test',
                                    family_name: 'Tester',
                                    email: 'test@digital.education.gov.uk',
                                    userRedirect: '/callback')
    sign_in_stub = WebMock.stub_request(:post, 'https://sign-in.com/services/123456789/invitations')
                          .with(body: sign_in_payload)
                          .to_return(status: 200, body: '', headers: {})

    create_invite = CreateInvite.new(user: user)
    create_invite.call

    WebMock.assert_requested(authorisation_stub)
    WebMock.assert_requested(sign_in_stub)
  end
end
