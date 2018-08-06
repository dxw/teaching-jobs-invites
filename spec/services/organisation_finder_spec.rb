require './services/organisation_finder'
require 'logger'

RSpec.describe OrganisationFinder do
  describe '.call' do
    before(:each) do
      stub_const(
        'OrganisationFinder::LOOKUP_TABLE',
        { '137138' => 'daf3ea45-2eaf-484b-9975-f2ef0af7eb37' }
      )
    end

    it 'returns the matching organisation_id for a given school_urn' do
      expect(described_class.call(school_urn: '137138'))
        .to eq('daf3ea45-2eaf-484b-9975-f2ef0af7eb37')
    end

    context 'when that school_urn does not match to an organisation_id' do
      before(:each) do
        stub_const(
          'OrganisationFinder::LOOKUP_TABLE',
          { '1' => '2' }
        )
      end

      it 'lets the user know that no attachment could be made' do
        mock_logger = instance_double(Logger)
        allow(Logger).to receive(:new).and_return(mock_logger)
        expect(mock_logger).to receive(:warn)
          .with('No organisation could be attached for 123, add manually.')

        result = described_class.call(school_urn: '123')

        expect(result).to eq(nil)
      end
    end
  end
end
