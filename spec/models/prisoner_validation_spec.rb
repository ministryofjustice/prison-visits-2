require 'rails_helper'

RSpec.describe PrisonerValidation, type: :model do
  let(:offender) do
    Nomis::Offender.new(id: 'someid', noms_id: 'a1234bc')
  end

  subject do
    described_class.new(offender)
  end

  context 'when the API finds a match' do
    context 'with a prisoner number, dob' do
      before do
        mock_nomis_with(:lookup_offender_location, establishment)
      end

      context 'and the location matches' do
        let(:establishment) { Nomis::Establishment.new(code: 'BMI', api_call_successful: true) }

        it { is_expected.to be_valid }

        it 'calls the api with a normalised noms_id' do
          expect_any_instance_of(Nomis::Api).
            to receive(:lookup_offender_location).
            with(noms_id: 'A1234BC').
            and_return(establishment)

          is_expected.to be_valid
        end

        describe '#prisoner_located_at?' do
          describe 'when prison code matches' do
            let(:code) { 'BMI' }

            it { is_expected.to be_prisoner_located_at(code) }
          end

          describe 'when prison code matches' do
            let(:code) { 'RANDOME_CODE' }

            it { is_expected.not_to be_prisoner_located_at(code) }
          end
        end
      end

      context 'and the location API call fails' do
        let(:establishment) { Nomis::Establishment.new(api_call_successful: false) }

        it 'is invalid an has a validation error for unknown state'do
          is_expected.not_to be_valid
          expect(subject.errors.full_messages).to eq(['location_unknown'])
        end
      end
    end
  end

  context 'API does not find a match' do
    let(:offender) { Nomis::NullOffender.new(api_call_successful: success) }

    describe 'with a successful API call' do
      let(:success) { true }

      it { is_expected.not_to be_valid }

      it 'does try to validate the location' do
        expect(Nomis::Api.instance).not_to receive(:lookup_offender_location)
        expect(subject).not_to be_valid
      end
    end

    context 'and the API does not find a match' do
      let(:offender) { Nomis::NullOffender.new }

      it { is_expected.not_to be_valid }
    end
  end
end
