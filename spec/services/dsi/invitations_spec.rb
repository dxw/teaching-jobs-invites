require './services/dsi/invitations'

RSpec.describe DSI::Invitations, type: :dsi do
  let(:bearer) { 'a-code' }

  context '.call' do
    let(:invitations) { described_class.new(user: user, organisation_id: nil) }
    let(:headers) { { 'Authorization': "bearer #{bearer}", 'Content-Type': 'application/json' } }
    let(:user) do
      { email: 'email@with_space.com   ', given_name: '  Given name',
        family_name: ' Family name ', school_urn: '123423   '}
    end
    let(:expected_json) do
      {
        sourceId: :user_id_in_your_service,
        given_name: 'Given name',
        family_name: 'Family name',
        email: 'email@with_space.com',
        userRedirect: nil,
        organisation: nil,
        inviteSubjectOverride: invitations.send(:email_subject),
        inviteBodyOverride: invitations.send(:email_copy)
      }.to_json
    end

    let(:request) { double(:request) }
    let(:connection) { double(:connection) }

    context 'successful' do
      let(:response) { double(:response, success?: true) }
      it 'strips surrounding space from all parameters' do
        allow(Faraday).to receive(:new).and_return(connection)

        expect(connection).to receive(:post).and_yield(request).and_return(response)
        expect(request).to receive(:body=).with(expected_json)
        expect(invitations.call).to eq(true)
      end

      it 'calls the service with the correct details' do
        expect(Faraday).to receive(:new).and_return(connection)
        expect(connection).to receive(:post).and_yield(request).and_return(response)
        expect(request).to receive(:body=).with(expected_json)

        invitations.call
      end

      it 'calls the service with the correct headers' do
        connection = double(:connection, post: response)

        expect(Faraday).to receive(:new).with('/dsi-url', headers: headers).and_return(connection)

        invitations.call
      end
    end

    context 'failed' do
      let(:response) { double(:response, success?: false, body: nil) }

      it 'raises an Exception' do
        connection = double(:connection, post: response)
        allow(Faraday).to receive(:new).with('/dsi-url', headers: headers).and_return(connection)

        expect { invitations.call }.to raise_error(DSI::InvitationFailed)
      end
    end
  end
end
