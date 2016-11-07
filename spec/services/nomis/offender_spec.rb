require "rails_helper"

RSpec.describe Nomis::Offender do

  subject(:offender) { described_class.get(noms_id, date_of_birth) }

  let(:nomis_api_enabled) { true }
  let(:noms_id)       { 'A1459AE' }
  let(:date_of_birth) { Date.parse('1976-06-12') }

  describe '.get' do

    before do
      allow(Nomis::Api).to receive(:enabled?).and_return(nomis_api_enabled)
    end

    describe 'when the NOMIS API is disabled' do
      let(:nomis_api_enabled) { false }

      it 'returns an invalid offender' do
        is_expected.to be_invalid
        expect(offender.errors.full_messages).to eq(['You must check NOMIS to verify prisoner date of birth and number.'])
      end
    end

    describe 'when the NOMIS API is enabled' do
      context 'and working correctly' do

        context 'with an exiting offender id', vcr: { cassette_name: 'lookup_active_offender' } do
          it 'returns an offender' do
            is_expected.to be_instance_of(described_class)
          end
        end

        context 'with a none exiting offender id', vcr: { cassette_name: 'lookup_active_offender-nomatch' } do
          let(:noms_id) { 'Z9999ZZ' }
          it 'returns nil' do
            is_expected.to be_nil
          end
        end
      end

    end
  end
end
