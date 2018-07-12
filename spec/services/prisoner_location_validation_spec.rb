require "rails_helper"

RSpec.describe PrisonerLocationValidation do
  let(:prisoner)       { Nomis::Prisoner.new(id: 'someid', noms_id: noms_id) }
  let(:noms_id)        { 'a1234bc' }
  let(:prison_code)    { 'BMI' }
  let(:code)           { prison_code }
  let(:api_successful) { true }
  let(:establishment)  do
    Nomis::Establishment.build(
      'establishment' => {
        'code' => code,
        'api_call_successful' => api_successful
      },
      'housing_location' => {
        'description' => 'Cell With View Overlooking the Ocean'
      }
    )
  end

  subject { described_class.new(prisoner, prison_code) }

  describe '#internal_location' do
    before do
      expect(subject).to receive(:valid?).and_return(is_valid)
    end

    context 'when the API call is successful' do
      let(:is_valid) { true }

      it 'returns the establishment' do
        mock_nomis_with(:lookup_prisoner_location, establishment)
        expect(subject.internal_location).to eq('Cell With View Overlooking the Ocean')
      end
    end

    context 'when the prisoner is not located at the given prison' do
      let(:is_valid) { false }

      it 'has no establishment' do
        expect(subject.internal_location).to be_nil
      end
    end
  end

  describe 'validation' do
    context 'with a valid prisoner' do
      context 'when the API call is successful' do
        before do
          mock_nomis_with(:lookup_prisoner_location, establishment)
        end

        context 'when the prisoner is located at the given prison' do
          it { is_expected.to be_valid }
        end

        context 'when the prisoner is not located at the given prison' do
          let(:code) { 'NOT_AT_THIS_PRISON_CODE' }

          it { is_expected.to be_invalid }
        end
      end

      context 'when the API call fails', :expect_exception do
        before do
          simulate_api_error_for :lookup_prisoner_location
        end

        it { is_expected.to be_invalid }
        it 'has an unknown location error' do
          subject.valid?
          expect(subject.errors.full_messages_for(:base)).
            to eq([described_class::UNKNOWN])
        end
      end
    end

    context 'with an invalid prisoner' do
      let(:noms_id) { nil }

      it 'is invalid' do
        expect(subject).to be_invalid
      end
    end
  end
end
