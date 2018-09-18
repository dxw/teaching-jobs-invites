require './services/create_dfe_sign_in_user'
require 'faraday'
require 'notifications/client'

RSpec.describe CreateDfeSignInUser, type: :dsi do
  context 'initialize' do
    let(:bearer) { 'token' }
    it 'strips surrounding space from all parameters' do
      allow(DSI::Organisations).to receive_message_chain(:new, :call).and_return(nil)

      request = double(:request, url: 'some url', headers: {})
      response = double(:response, success?: true)

      user = { email: 'email@with_space.com   ',
               given_name: '  Given name',
               family_name: ' Family name ',
               school_urn: '123423   '}

      expect(DSI::Organisations).to receive_message_chain(:new, :find).with('123423')

      create_dfe_sign_in_user = described_class.new(user: user)
      expect(JWT).to receive(:encode)
      expect(Faraday).to receive_message_chain(:new, :post).and_yield(request).and_return(response)

      expected_json = {
        sourceId: :user_id_in_your_service,
        given_name: 'Given name',
        family_name: 'Family name',
        email: 'email@with_space.com',
        userRedirect: nil,
        organisation: nil,
        inviteSubjectOverride: create_dfe_sign_in_user.send(:email_subject),
        inviteBodyOverride: create_dfe_sign_in_user.send(:email_copy)
      }.to_json

      expect(request).to receive(:body=).with(expected_json)

      create_dfe_sign_in_user.call
    end
  end
end
