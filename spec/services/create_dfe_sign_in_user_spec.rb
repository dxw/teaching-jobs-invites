require './services/organisation_finder'
require './services/create_dfe_sign_in_user'
require 'faraday'
require 'notifications/client'

RSpec.describe CreateDfeSignInUser do
  context 'initialize' do
    it 'strips surrounding space from all parameters' do
      organisation_finder = OrganisationFinder.new
      request = double(:request, url: 'some url', headers: {})
      response = double(:response, success?: true)

      user = { email: 'email@with_space.com   ',
               given_name: '  Given name',
               family_name: ' Family name ',
               school_urn: '123423   '}

      create_dfe_sign_in_user = described_class.new(user: user, organisation_finder: organisation_finder)
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
