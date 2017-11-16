require "rails_helper"

RSpec.describe PrisonerLocation do
  let(:offender)       { Nomis::Offender.new(id: 'someid', noms_id: 'a1234bc') }
  let(:prison_code)    { 'BMI' }
  let(:establishment)  { Nomis::Establishment.new(code: code, api_call_successful: api_successful) }

  subject { described_class.new(offender, prison_code) }

  describe 'validation' do
    context 'when the API call is successful' do
      before do
        mock_nomis_with(:lookup_offender_location, establishment)
      end

      let(:api_successful) { true }

      context 'when the offender is located at the given prison' do
        let(:code)  { prison_code }

        it { is_expected.to be_valid }
      end

      context 'when the offender is not located at the given prison' do
        let(:code) { 'NOT_AT_THIS_PRISON_CODE' }

        it { is_expected.to be_invalid }
      end
    end

    context 'when the API call fails' do
      before do
        simulate_api_error_for :lookup_offender_location
      end

      it { is_expected.to be_invalid }
      it 'has an unknown location error' do
        subject.valid?
        expect(subject.errors.full_messages_for(:base)).
                 to eq([described_class::UNKNOWN])
      end
    end
  end
end
