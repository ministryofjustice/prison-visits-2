require 'rails_helper'
require 'nomis/client'

RSpec.describe PrisonerAvailabilityValidation, type: :model do
  subject do
    described_class.new(offender: offender,
                        requested_slots: requested_slots)
  end

  let(:offender) { Nomis::Offender.new(id: '123', noms_id: 'some_prisoner_number') }
  let(:date1) { 2.days.from_now.to_date }
  let(:slot1) { ConcreteSlot.new(date1.year, date1.month, date1.day, 10, 0, 11, 0) }
  let(:date2) { 1.day.from_now.to_date }
  let(:slot2) { ConcreteSlot.new(date2.year, date2.month, date2.day, 10, 0, 11, 0) }
  let(:date3) { 3.days.from_now.to_date }
  let(:slot3) { ConcreteSlot.new(date3.year, date3.month, date3.day, 10, 0, 11, 0) }
  let(:requested_slots) { [slot1, slot2, slot3] }

  describe 'when the NOMIS API is disabled' do
    before do
      allow(Nomis::Api).to receive(:enabled?).and_return(false)
      subject.valid?
    end

    it "doesn't add errors to the dates" do
      requested_slots.each do |slot|
        expect(subject.errors[slot.to_s]).to be_empty
      end
    end

    it 'is unknown result' do
      expect(subject).to be_unknown_result
    end
  end

  describe 'when the NOMIS API is enabled' do
    context 'when the api returns an error' do
      before do
        expect_any_instance_of(Nomis::Client).
          to receive(:get).and_raise(Nomis::APIError)
      end

      it 'adds no errors for any slot' do
        is_expected.to be_valid

        requested_slots.each do |slot|
          expect(subject.errors[slot.to_s]).to be_empty
        end
      end

      it 'is unknown result' do
        subject.valid?

        expect(subject).to be_unknown_result
      end
    end

    context 'when working correctly with some unavailable slots' do
      let(:date1_availability) do
        {
          date: slot1.to_date,
          banned: false,
          out_of_vo: false,
          external_movement: false,
          existing_visits: []
        }
      end

      let(:date2_availability) do
        {
          date: slot2.to_date,
          banned: true,
          out_of_vo: true,
          external_movement: false,
          existing_visits: []
        }
      end

      let(:date3_availability) do
        {
          date: slot3.to_date,
          banned: false,
          out_of_vo: false,
          external_movement: false,
          existing_visits: []
        }
      end

      before do
        availability = Nomis::PrisonerDetailedAvailability.new(
          dates: [date1_availability, date2_availability, date3_availability])
        expect(Nomis::Api.instance).
          to receive(:offender_visiting_detailed_availability).
          with(offender_id: offender.id, slots: [slot1, slot2, slot3]).
          and_return(availability)

        subject.valid?
      end

      context 'with slots that are available' do
        it 'does not add an error to the slot' do
          expect(subject.errors[slot1.to_s]).to be_empty
        end

        context 'with #slot_errors' do
          it 'returns nothing' do
            expect(subject.slot_errors(slot1)).to be_empty
          end
        end

        it { is_expected.not_to be_unknown_result }
      end

      context 'with dates that are unavailable' do
        it 'adds an error to the slot' do
          expect(subject.errors[slot2.to_s]).
            to eq([Nomis::PrisonerDateAvailability::OUT_OF_VO])
        end

        context 'with #slot_errors' do
          it 'returns the prisoner availability error' do
            expect(subject.slot_errors(slot2)).
              to eq([Nomis::PrisonerDateAvailability::OUT_OF_VO])
          end
        end

        it { is_expected.not_to be_unknown_result }
      end
    end

    context 'when the API is enabled and with invalid dates' do
      before do
        allow(Nomis::Api).to receive(:enabled?).and_return(true)
      end

      context 'with all the dates in the past' do
        let(:date1) { 1.day.ago.to_date }
        let(:date2) { 2.days.ago.to_date }
        let(:date3) { 3.days.ago.to_date }

        # We return the dates as valid because it doesn't make sense to
        # communicate that the prisoner is unavailable just because the date is
        # in the past. Another validator should be responsible for that.
        it 'does not add errors to the slots' do
          expect_any_instance_of(Nomis::Api).
            not_to receive(:offender_visiting_detailed_availability)

          subject.valid?

          requested_slots.each do |slot|
            expect(subject.slot_errors(slot)).to be_empty
          end
        end

        it { is_expected.not_to be_unknown_result }
      end

      context 'with some dates in the past' do
        let(:date1) { 1.day.ago.to_date }
        let(:date2) { 61.days.from_now.to_date }
        let(:availability3) do
          { date: date3, external_movement: true }
        end

        before do
          expect_any_instance_of(Nomis::Api).
            to receive(:offender_visiting_detailed_availability).
            with(offender_id: offender.id,
                 slots: [slot3]).
            and_return(Nomis::PrisonerDetailedAvailability.new(dates: [availability3]))
        end

        it 'filters out invalid dates' do
          subject.valid?

          expect(subject.slot_errors(slot1)).to be_empty
          expect(subject.slot_errors(slot2)).to be_empty
          expect(subject.slot_errors(slot3)).
            to eq([Nomis::PrisonerDateAvailability::EXTERNAL_MOVEMENT])
        end

        it { is_expected.not_to be_unknown_result }
      end
    end

    context 'when the API is enabled and with invalid offender' do
      let(:offender) { Nomis::NullOffender.new }

      it { is_expected.to be_unknown_result }
    end
  end
end
