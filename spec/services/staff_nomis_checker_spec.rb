require 'rails_helper'

RSpec.describe StaffNomisChecker do
  let(:instance) { described_class.new(visit) }
  let(:visit)    { build_stubbed(:visit, prisoner: prisoner) }
  let(:prisoner) { build_stubbed(:prisoner) }
  let(:offender) { Nomis::Offender.new(id: visit.prisoner_id) }
  let(:enabled)  { true }

  before do
    allow(Nomis::Api).to receive(:enabled?).and_return(enabled)
    allow(instance).to receive(:offender).and_return(offender)
  end

  describe '#prisoner_existance_status' do
    subject { instance.prisoner_existance_status }

    describe 'when the nomis api is not live' do
      let(:enabled) { false }
      it { is_expected.to eq('not_live') }
    end

    describe 'when the nomis api is live' do
      before do
        expect(PrisonerValidation).to receive(:new).with(offender).and_return(validator)
      end

      let(:validator) do
        double(PrisonerValidation, valid?: true, errors: { base: errors })
      end

      describe 'and there are no errors' do
        let(:errors) { [] }

        it { is_expected.to eq('valid') }
      end

      describe "and the error is 'unknown'" do
        let(:errors) { ['unknown'] }

        it { is_expected.to eq('unknown') }
      end

      describe "and the error is 'prisoner_does_not_exist'" do
        let(:errors) { ['prisoner_does_not_exist'] }

        it { is_expected.to eq('invalid') }
      end
    end
  end

  describe '#prisoner_existance_error' do
    let(:offender) { Nomis::NullOffender.new(api_call_successful: true) }

    it 'is the error from the prisoner validation' do
      expect(instance.prisoner_existance_error).to eq('prisoner_does_not_exist')
    end
  end

  describe '#errors_for' do
    subject { instance.errors_for(slot) }
    let(:slot) { visit.slots.first }

    context 'when the nomis api is not enabled' do
      let(:enabled) { false }

      it { is_expected.to be_empty }
    end

    context 'when the nomis api is enabled' do
      let(:enabled) { true }

      before do
        allow(instance).to receive(:offender).and_return(offender)
      end

      context 'and a valid offender' do
        let(:offender) { Nomis::Offender.new(id: '1234') }

        let(:validator) do
          double(PrisonerAvailabilityValidation, valid?: false)
        end
        let(:message) { PrisonerAvailabilityValidation::PRISONER_NOT_AVAILABLE }

        before do
          allow(PrisonerAvailabilityValidation).
            to receive(:new).
            with(offender: offender, requested_dates: visit.slots.map(&:to_date)).
            and_return(validator)
          expect(validator).
            to receive(:date_error).with(visit.slots.first.to_date).
            and_return(message)
        end

        it { is_expected.to eq([message]) }
      end

      context 'a null offender' do
        let(:offender) { Nomis::NullOffender.new }

        it { is_expected.to eq([]) }
      end
    end
  end
end
