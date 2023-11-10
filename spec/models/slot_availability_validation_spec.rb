require 'rails_helper'

RSpec.describe SlotAvailabilityValidation, type: :model do
  subject do
    described_class.new(prison:, requested_slots:)
  end

  let(:prison) { build_stubbed(:prison) }
  let(:slot1) do
    date = 6.days.from_now.to_date
    ConcreteSlot.new(date.year, date.month, date.day, 14, 30, 15, 30)
  end
  let(:slot2) do
    date = 5.days.from_now.to_date
    ConcreteSlot.new(date.year, date.month, date.day, 14, 30, 15, 30)
  end
  let(:slot3) do
    date = 4.days.from_now.to_date
    ConcreteSlot.new(date.year, date.month, date.day, 14, 30, 15, 30)
  end
  let(:requested_slots) { [slot1, slot2, slot3] }
  let(:api_slots) do
    available_slots.map do |slot|
      { 'time' => slot.to_s, 'max_adults' => anything }
    end
  end

  describe 'when the NOMIS API is disabled' do
    before do
      allow(Nomis::Api).to receive(:enabled?).and_return(false)
      subject.valid?
    end

    it "doesn't add an error to the slots" do
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
        expect_any_instance_of(Nomis::Client)
          .to receive(:get).and_raise(Nomis::APIError)
      end

      it 'adds no errors for any slot' do
        expect(subject).to be_valid

        requested_slots.each do |slot|
          expect(subject.errors[slot.to_s]).to be_empty
        end
      end

      it 'is unknown result' do
        subject.valid?

        expect(subject).to be_unknown_result
      end
    end

    context 'when working correctly with valid slots' do
      before do
        allow(Nomis::Api).to receive(:enabled?).and_return(true)

        expect(Nomis::Api.instance)
          .to receive(:fetch_bookable_slots)
          .with(prison:,
                start_date: slot3.to_date,
                end_date: slot1.to_date)
          .and_return(Nomis::SlotAvailability.new(slots: api_slots))

        subject.valid?
      end

      context 'with dates that are available' do
        let(:available_slots) { [slot1] }

        it 'does not add an error to the slot' do
          expect(subject.errors[slot1.to_s]).to be_blank
        end

        context 'with a #slot_error' do
          it 'returns nothing' do
            expect(subject.slot_error(slot1)).to be_nil
          end
        end

        it { is_expected.not_to be_unknown_result }
      end

      context 'when the slots that are unavailable' do
        let(:available_slots) { [slot1, slot3] }

        it 'adds an error to the missing slot' do
          expect(subject.errors[slot2.to_s])
            .to eq([described_class::SLOT_NOT_AVAILABLE])
        end

        context 'with a #slot_error' do
          it 'returns the slot not available message' do
            expect(subject.slot_error(slot2))
              .to eq(described_class::SLOT_NOT_AVAILABLE)
          end
        end

        it { is_expected.not_to be_unknown_result }
      end
    end

    context 'when the API enabled and with invalid dates' do
      before do
        allow(Nomis::Api).to receive(:enabled?).and_return(true)
      end

      context 'with all the dates in the past' do
        let(:slot1) do
          date = 1.day.ago.to_date
          ConcreteSlot.new(date.year, date.month, date.day, 14, 30, 15, 30)
        end
        let(:slot2) do
          date = 2.days.ago.to_date
          ConcreteSlot.new(date.year, date.month, date.day, 14, 30, 15, 30)
        end
        let(:slot3) do
          date = 3.days.ago.to_date
          ConcreteSlot.new(date.year, date.month, date.day, 14, 30, 15, 30)
        end

        # We return the dates as valid because it doesn't make sense to
        # communicate that the prisoner is unavailable just because the date is
        # in the past. Another validator will be responsible for that.
        it 'returns all the slots' do
          expect_any_instance_of(Nomis::Api).not_to receive(:fetch_bookable_slots)

          subject.valid?

          requested_slots.each do |slot|
            expect(subject.slot_error(slot)).to be_nil
          end
        end

        it { is_expected.not_to be_unknown_result }
      end

      context 'with dates in the past or too far in the future' do
        # API only allows dates for following day the earliest
        let(:slot1) do
          date = Date.current
          ConcreteSlot.new(date.year, date.month, date.day, 14, 30, 15, 30)
        end
        let(:slot2) do
          date = 61.days.from_now.to_date
          ConcreteSlot.new(date.year, date.month, date.day, 14, 30, 15, 30)
        end

        before do
          expect_any_instance_of(Nomis::Api)
            .to receive(:fetch_bookable_slots)
            .with(prison:,
                  start_date: slot3.to_date,
                  end_date: slot3.to_date)
            .and_return(Nomis::SlotAvailability.new(slots: []))
        end

        it 'filters out invalid dates' do
          subject.valid?

          expect(subject.slot_error(slot1)).to be_nil
          expect(subject.slot_error(slot2)).to be_nil
          expect(subject.slot_error(slot3))
            .to eq(described_class::SLOT_NOT_AVAILABLE)
        end

        it { is_expected.not_to be_unknown_result }
      end
    end
  end
end
