require 'rails_helper'

RSpec.describe ApiPrisonerChecker do
  subject(:instance) do
    described_class.new(noms_id: noms_id, date_of_birth: date_of_birth)
  end

  let(:noms_id) { 'A1234BC' }
  let(:date_of_birth) { Time.zone.today }

  describe '#valid?' do
    context 'when the api is disabled' do
      before do
        allow(Nomis::Api).to receive(:enabled?).and_return(false)
      end

      it { is_expected.to be_valid }
    end

    context 'when the api is enabled' do
      before do
        allow(Nomis::Api).to receive(:enabled?).and_return(true)
      end

      context 'and the api is working' do
        before do
          expect(Nomis::Api.instance).
            to receive(:lookup_active_offender).
            and_return(offender)
        end

        describe 'when the offender is found' do
          let(:offender) { Nomis::Offender.new(id: '1234') }
          it { is_expected.to be_valid }
        end

        describe 'when the offender is not found' do
          let(:offender) { Nomis::NullOffender.new(api_call_successful: true) }
          it { is_expected.to_not be_valid }
        end
      end

      describe "when the api call fails" do
        before do
          allow_any_instance_of(Nomis::Client).
            to receive(:get).and_raise(Nomis::APIError)
        end

        it { is_expected.to be_valid }
      end
    end
  end

  describe '#error' do
    let(:errors) { ['something'] }

    before do
      allow(Nomis::Api).to receive(:enabled?).and_return(false)
      allow_any_instance_of(PrisonerValidation).to receive(:valid?)
      allow_any_instance_of(PrisonerValidation).
        to receive(:errors).and_return(base: errors)
    end

    it 'returns the error from the validator' do
      expect(subject.error).to eq('something')
    end
  end
end
