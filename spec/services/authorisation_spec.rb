require './services/authorisation'

RSpec.describe Authorisation do
  context '.preauthorise' do
    before(:each) do
      allow(Faraday).to receive(:new).and_return(connection)
    end

    let(:request) { double(:request, headers: {}) }
    let(:connection) { double(:connection) }
    let(:user) { { email: 'user@email.com', school_urn: '123123' } }

    context 'successful' do
      let(:response) { double(:response, success?: true) }
      it 'authorises the user' do
        expected_json = { user_token: 'user@email.com', school_urn: '123123' }.to_json

        expect(connection).to receive(:post).and_yield(request).and_return(response)
        expect(request).to receive(:url).with('/permissions')
        expect(request).to receive(:body=).with(expected_json)

        expect(Logger).to receive_message_chain(:new, :info).with('Preauthorised user@email.com for 123123')
        expect(Authorisation.new(user).preauthorise).to eq(true)
      end
    end

    context 'failed' do
      let(:response) { double(:response, success?: false, body: nil) }
      let(:connection) { double(:connection, post: response) }

      it 'raises an Exception' do
        expect(Logger).to_not receive(:new)
        expect { Authorisation.new(user).preauthorise }.to raise_error(AuthorisationFailed)
      end
    end
  end
end
