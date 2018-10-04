require './services/authorisation'

RSpec.describe SendEmail do
  context '.call' do
    before(:each) do
      allow(Notifications::Client).to receive(:new).and_return(notify)
    end

    let(:request) { double(:request, headers: {}) }
    let(:notify) { double(:notify) }
    let(:user) { { email: 'user@email.com', school_urn: '123123' } }

    context '#send_single_welcome_email' do
      it 'sends single_welcome_email to user with one school' do
        user = { schools: [school_name: 'Hogwards'],
                 email: 'test@email.com',
                 given_name: 'Jane',
                 family_name: 'Doe'}

        expected_json =  {
          email_address: user[:email],
          template_id: ENV['NOTIFY_WELCOME_SINGLE_TEMPLATE_ID'],
          personalisation: {
            first_name: user[:given_name],
            family_name: user[:family_name],
            email_address: user[:email],
            school_name: user[:schools].first[:school_name]
          },
          reference: 'welcome-to-teaching-jobs-email'
        }

        expect(notify).to receive(:send_email).with(expected_json)
        expect(Logger).to receive_message_chain(:new, :info)
          .with('Sent welcome email to test@email.com for Hogwards')

        SendEmail.new(user).call
      end
    end

    context '#send_trust_welcome_email' do
      it 'sends single_welcome_email to user with one school' do
        user = { schools: [{school_name: :one}, {school_name: :two}],
                 email: 'test@email.com',
                 given_name: 'Jane',
                 family_name: 'Doe'}

        expected_json =  {
          email_address: user[:email],
          template_id: ENV['NOTIFY_WELCOME_TRUST_TEMPLATE_ID'],
          personalisation: {
            first_name: user[:given_name],
            family_name: user[:family_name],
            email_address: user[:email],
            school_name: "2 schools",
            trust_name: 'your trust'
          },
          reference: 'welcome-to-teaching-jobs-email'
        }

        expect(notify).to receive(:send_email).with(expected_json)
        expect(Logger).to receive_message_chain(:new, :info)
          .with('Sent welcome email to test@email.com for 2 schools')

        SendEmail.new(user).call
      end
    end
  end
end
