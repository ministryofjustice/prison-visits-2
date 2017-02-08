require 'rails_helper'

RSpec.describe StaffNomisChecker do
  let(:instance) { described_class.new(visit) }

  # Enabled for slot availability
  let(:prison)   { build_stubbed(:prison, name: 'Pentonville') }
  let(:visit)    { build_stubbed(:visit, prisoner: prisoner, prison: prison) }
  let(:prisoner) { build_stubbed(:prisoner) }
  let(:offender) { Nomis::Offender.new(id: prisoner.number) }
  let(:api_enabled) { true }

  before do
    allow(Nomis::Api).to receive(:enabled?).and_return(api_enabled)
    allow(instance).to receive(:offender).and_return(offender)
    allow(Rails.configuration).
      to receive(:staff_prisons_with_slot_availability).
      and_return(%w[Pentonville Cardiff])
  end

  describe '#prisoner_existance_status' do
    subject { instance.prisoner_existance_status }

    describe 'when the nomis api is not live' do
      let(:api_enabled) { false }
      it { is_expected.to eq('not_live') }
    end

    describe 'api is configured and the check is disabled for staff' do
      let(:api_enabled) { true }

      before do
        allow(Rails.configuration).
          to receive(:nomis_staff_prisoner_check_enabled).
          and_return(false)
      end

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

  describe '#prisoner_availability_unknown?' do
    subject { instance.prisoner_availability_unknown? }

    context 'when the nomis api is disabled' do
      let(:api_enabled) { false }

      it { is_expected.to eq(false) }
    end

    context 'when the api is enabled and the flag is disabled' do
      let(:api_enabled) { true }

      before do
        allow(Rails.configuration).
          to receive(:nomis_staff_prisoner_availability_enabled).
          and_return(false)
      end

      it { is_expected.to eq(false) }
    end

    context 'when the validator returns unknown' do
      before do
        allow_any_instance_of(PrisonerAvailabilityValidation).
          to receive(:unknown_result?).and_return(true)
      end

      it { is_expected.to eq(true) }
    end

    context 'when the validator returns not unknown' do
      before do
        allow_any_instance_of(PrisonerAvailabilityValidation).
          to receive(:valid?)
        allow_any_instance_of(PrisonerAvailabilityValidation).
          to receive(:unknown_result?).and_return(false)
      end

      it { is_expected.to eq(false) }
    end
  end

  describe '#slot_availability_unknown?' do
    subject { instance.slot_availability_unknown? }

    context 'when the nomis api is disabled' do
      let(:api_enabled) { false }

      it { is_expected.to eq(false) }
    end

    context 'when the api is enabled and the flag is disabled' do
      let(:api_enabled) { true }

      before do
        allow(Rails.configuration).
          to receive(:nomis_staff_slot_availability_enabled).
          and_return(false)
      end

      it { is_expected.to eq(false) }
    end

    context "when the feature is enabled" do
      before do
        allow(Rails.configuration).
          to receive(:nomis_staff_slot_availability_enabled).
          and_return(true)
      end

      context 'when the validator returns unknown' do
        before do
          allow_any_instance_of(SlotAvailabilityValidation).
            to receive(:unknown_result?).and_return(true)
        end

        it { is_expected.to eq(true) }
      end

      context 'when the validator returns not unknown' do
        before do
          allow_any_instance_of(SlotAvailabilityValidation).
            to receive(:valid?)
          allow_any_instance_of(SlotAvailabilityValidation).
            to receive(:unknown_result?).and_return(false)
        end

        it { is_expected.to eq(false) }
      end
    end
  end

  describe '#errors_for' do
    subject { instance.errors_for(slot) }
    let(:slot) { visit.slots.first }

    context 'when the nomis api is not enabled' do
      let(:api_enabled) { false }

      it { is_expected.to be_empty }
    end

    context 'when the nomis api is enabled' do
      let(:api_enabled) { true }

      before do
        allow(instance).to receive(:offender).and_return(offender)
      end

      context 'prisoner availability' do
        before do
          allow_any_instance_of(SlotAvailabilityValidation).
            to receive(:valid?).and_return(true)
        end

        context 'prisoner availability flag is disabled' do
          before do
            allow(Rails.configuration).
              to receive(:nomis_staff_prisoner_availability_enabled).
              and_return(false)
          end

          it { is_expected.to be_empty }
        end

        context 'and a valid offender' do
          let(:offender) { Nomis::Offender.new(id: '1234') }

          let(:validator) do
            double(PrisonerAvailabilityValidation, valid?: false)
          end

          before do
            allow(PrisonerAvailabilityValidation).
              to receive(:new).
              with(offender: offender, requested_dates: visit.slots.map(&:to_date)).
              and_return(validator)

            expect(validator).
              to receive(:date_error).with(visit.slots.first.to_date).
              and_return(message)
          end

          context 'with an error' do
            let(:message) { PrisonerAvailabilityValidation::PRISONER_NOT_AVAILABLE }

            it { is_expected.to eq([message]) }
          end

          context 'with no errors' do
            let(:message) { nil }

            it { is_expected.to be_empty }
          end
        end

        context 'a null offender' do
          let(:offender) { Nomis::NullOffender.new }

          it { is_expected.to eq([]) }
        end
      end

      context 'slot availability' do
        let(:offender) { Nomis::NullOffender.new }
        let(:validator) { double(SlotAvailabilityValidation, valid?: false) }

        before do
          allow_any_instance_of(PrisonerAvailabilityValidation).
            to receive(:date_error).and_return(nil)

          allow(SlotAvailabilityValidation).
            to receive(:new).
            with(visit: visit).
            and_return(validator)
        end

        context 'with slot availability disabled' do
          before do
            allow(validator).
              to receive(:slot_error).
              with(visit.slots.first).
              and_return(anything)
          end

          describe 'due to the staff availability being disabled' do
            before do
              expect(Rails.configuration).
                to receive(:nomis_staff_slot_availability_enabled).
                and_return(false)
            end

            it { is_expected.to eq([]) }
          end

          describe 'due to the prison not being enabled' do
            before do
              allow(Rails.configuration).
                to receive(:nomis_staff_slot_availability_enabled).
                and_return(true)

              expect(Rails.configuration).
                to receive(:staff_prisons_with_slot_availability).
                and_return([])
            end

            it { is_expected.to eq([]) }
          end
        end

        context 'with slot availability enabled' do
          before do
            allow(Rails.configuration).
              to receive(:nomis_staff_slot_availability_enabled).
              and_return(true)

            expect(validator).
              to receive(:slot_error).
              with(visit.slots.first).
              and_return(message)
          end

          context 'with no errors' do
            let(:message) { nil }

            it { is_expected.to eq([]) }
          end

          context 'with an error' do
            let(:message) { SlotAvailabilityValidation::SLOT_NOT_AVAILABLE }

            it { is_expected.to eq([message]) }
          end
        end
      end
    end
  end

  describe '#slots_unavailable?' do
    subject { instance.slots_unavailable? }

    describe 'when the slots have expired' do
      before do
        now = Date.current
        allow(visit).
          to receive(:slots).
          and_return([
            ConcreteSlot.new(2015, 10, 5, 11, 30, 12, 30),
            ConcreteSlot.new(now.year, now.month, now.day, 14, 30, 15, 30)
          ])
      end

      it { is_expected.to eq(true) }
    end

    describe 'when the slots are unavailable' do
      before do
        allow(instance).
          to receive(:errors_for).
          with(anything).
          and_return([SlotAvailabilityValidation::SLOT_NOT_AVAILABLE])
      end

      it { is_expected.to eq(true) }
    end

    describe 'when a future slot is available' do
      let(:slot1) do
        date = Date.current + 3.days
        ConcreteSlot.new(date.year, date.month, date.day, 12, 0, 13, 0)
      end

      let(:slot2) do
        date = Date.current + 2.days
        ConcreteSlot.new(date.year, date.month, date.day, 12, 0, 13, 0)
      end

      let(:slot3) do
        date = Date.current - 2.days
        ConcreteSlot.new(date.year, date.month, date.day, 12, 0, 13, 0)
      end

      before do
        allow(visit).to receive(:slots).and_return([slot1, slot2, slot3])

        allow(instance).to receive(:errors_for).with(slot1).and_return([])

        allow(instance).
          to receive(:errors_for).
          with(slot2).
          and_return([SlotAvailabilityValidation::SLOT_NOT_AVAILABLE])
      end

      it { is_expected.to eq(false) }
    end
  end
end
