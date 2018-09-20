require './services/dsi/organisations'

RSpec.describe DSI::Organisations, type: :dsi do
  let(:bearer) { 'bearer-token' }
  let(:urn) { '12323' }

  context '.find' do
    let(:headers) { { 'Authorization': "bearer #{bearer}", 'Content-Type': 'application/json' } }
    let(:request) { double(:request) }
    let(:connection) { double(:connection) }

    context 'successful' do
      let(:response) { double(:response, success?: true, body: { id: 'org-id' }.to_json) }

      it 'calls the service with the correct details' do
        expect(Faraday).to receive(:new).and_return(connection)
        expect(connection).to receive(:get)
          .with("/organisations/find-by-type/001/#{urn}").and_return(response)

        expect(DSI::Organisations.new(school_urn: urn).find).to eq('org-id')
      end

      it 'calls the service with the correct headers' do
        connection = double(:connection, get: response)

        expect(Faraday).to receive(:new).with('/dsi-url', headers: headers).and_return(connection)

        DSI::Organisations.new(school_urn: urn).find
      end
    end

    context 'failed' do
      let(:response) { double(:response, success?: false, body: nil) }

      it 'logs the failure' do
        connection = double(:connection, get: response)
        allow(Faraday).to receive(:new).with('/dsi-url', headers: headers).and_return(connection)

        expect(Logger).to receive_message_chain(:new, :info)
          .with("Unable to find a DSI Organisation associated with school urn #{urn}")
        expect(DSI::Organisations.new(school_urn: urn).find).to eq(nil)
      end
    end
  end
end
