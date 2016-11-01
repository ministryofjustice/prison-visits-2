require 'rails_helper'

RSpec.describe PrisonerValidation, type: :model do
  subject do
    described_class.new(noms_id: 'A1234BC',
                        date_of_birth: Time.zone.today)
  end

  describe 'when the NOMIS API is disabled' do
    before do
      allow(Nomis::Api).to receive(:enabled?).and_return(false)
    end

    it 'the result is unknown' do
      is_expected.to_not be_valid
      expect(subject.errors[:base]).to eq(['unknown'])
    end
  end

  describe 'when the NOMIS API is enabled' do
    context 'and working correctly' do
      before do
        allow(Nomis::Api).to receive(:enabled?).and_return(true)

        allow_any_instance_of(Nomis::Api).
          to receive(:lookup_active_offender).
          with(noms_id: 'A1234BC',
               date_of_birth: Time.zone.today).
          and_return(api_response)
      end

      context 'and the API finds a match' do
        let(:api_response) { double('offender') }

        it { is_expected.to be_valid }
      end

      context 'and the API does not find a match' do
        let(:api_response) { nil }

        it { is_expected.to_not be_valid }
      end
    end

    context 'and the API raises an error' do
      before do
        allow_any_instance_of(Nomis::Api).
          to receive(:lookup_active_offender).
          and_raise(Excon::Errors::Error.new)
      end

      it { is_expected.to_not be_valid }
    end
  end
end
