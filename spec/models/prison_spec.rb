require 'rails_helper'

RSpec.describe Prison, type: :model do
  before do
    subject.lead_days = 3
    subject.weekend_processing = false
  end

  describe 'first_bookable_date' do
    #
    #    Th Fr Sa Su Mo Tu We Th Fr Sa Su Mo
    #     1  2  3  4  5  6  7  8  9 10 11 12
    #     T  1  .  .  2  3  *  *  *  .  .  *
    #     |              |  |<--------->|
    #   Today       Confirm    Bookable

    let(:today) { Date.new(2015, 10, 1) }
    let(:wednesday) { Date.new(2015, 10, 7) }

    it 'is the day after the lead time' do
      expect(subject.first_bookable_date(today)).to eq(wednesday)
    end
  end

  describe 'last_bookable_date' do
    it 'is [booking_window] full days from tomorrow' do
      subject.booking_window = 10
      today = Date.new(2015, 10, 1)
      expect(subject.last_bookable_date(today)).to eq(Date.new(2015, 10, 11))
    end
  end

  context 'available slots and bookability' do
    before do
      #
      #    Th Fr Sa Su Mo Tu We Th Fr Sa Su Mo
      #     1  2  3  4  5  6  7  8  9 10 11 12
      #     T  1  .  .  2  3  *  *  *  .  .  *
      #     |              |  |<--------->|
      #   Today       Confirm    Bookable
      subject.slot_details = {
        'recurring' => {
          'mon' => ['1001-1100'],
          'tue' => ['1002-1100'],
          'wed' => ['1003-1100'],
          'thu' => ['1004-1100'],
          'fri' => ['1005-1100'],
          'sat' => ['1006-1100'],
          'sun' => ['1007-1100']
        }
      }
      subject.booking_window = 10
    end

    let(:today) { Date.new(2015, 10, 1) } # Thursday

    describe 'available_slots' do
      it 'enumerates available slots within booking window starting after lead time' do
        expect(subject.available_slots(today).to_a).to eq(
          [
            ConcreteSlot.new(2015, 10,  7, 10, 3, 11, 0),
            ConcreteSlot.new(2015, 10,  8, 10, 4, 11, 0),
            ConcreteSlot.new(2015, 10,  9, 10, 5, 11, 0),
            ConcreteSlot.new(2015, 10, 10, 10, 6, 11, 0),
            ConcreteSlot.new(2015, 10, 11, 10, 7, 11, 0)
          ]
        )
      end
    end

    describe 'bookable_date?' do
      around do |example|
        travel_to today do
          example.run
        end
      end

      it 'returns true if a slot is within the available range' do
        requested_date = Date.new(2015, 10, 10)
        expect(subject.bookable_date?(requested_date)).to be_truthy
      end

      it 'returns false if a slot is not within the available range' do
        first_date = Date.new(2015, 10, 12)
        second_date = Date.new(2015, 10, 6)

        expect(subject.bookable_date?(first_date)).to be_falsey
        expect(subject.bookable_date?(second_date)).to be_falsey
      end
    end
  end

  describe 'confirm_by' do
    context 'when the lead days are not broken up by a holiday or weekend' do
      #
      #    16 17 18 19 20 21 22 23 24 25 26 27 28 29
      #    Mo Tu We Th Fr Sa Su Mo Tu We Th Fr Sa Su
      #     T  1  2  3  *  .  .  *  *  *  *  *  .  .
      #     |        |
      #   Today   Confirm

      let(:thursday) { Date.new(2015, 11, 19) }
      let(:monday) { Date.new(2015, 11, 16) }

      it 'returns a date [lead days] days from now' do
        expect(subject.confirm_by(monday)).to eq(thursday)
      end
    end

    context 'when the lead days are broken up by the weekend' do
      context 'when a prison doesn’t process at the weekend' do
        #
        #    16 17 18 19 20 21 22 23 24 25 26 27 28 29
        #    Mo Tu We Th Fr Sa Su Mo Tu We Th Fr Sa Su
        #     *  *  *  T  1  .  .  2  3  *  *  *  .  .
        #              |              |
        #            Today         Confirm

        let(:thursday) { Date.new(2015, 11, 19) }
        let(:tuesday) { Date.new(2015, 11, 24) }

        it 'skips Saturday and Sunday' do
          expect(subject.confirm_by(thursday)).to eq tuesday
        end
      end

      context 'when a prison processes visits at the weekend' do
        #
        #    16 17 18 19 20 21 22 23 24 25 26 27 28 29
        #    Mo Tu We Th Fr Sa Su Mo Tu We Th Fr Sa Su
        #     *  *  *  T  1  2  3  *  *  *  *  *  *  *
        #              |        |
        #            Today   Confirm

        let(:thursday) { Date.new(2015, 11, 19) }
        let(:sunday) { Date.new(2015, 11, 22) }

        before do
          subject.weekend_processing = true
        end

        it 'includes Saturday and Sunday' do
          expect(subject.confirm_by(thursday)).to eq(sunday)
        end
      end
    end

    context 'when the lead days are broken up by a public holiday' do
      #
      #    16 17 18 19 20 21 22 23 24 25 26 27 28 29
      #    Mo Tu We Th Fr Sa Su Mo Tu We Th Fr Sa Su
      #     *  *  *  T  1  .  .  H  2  3  *  *  .  .
      #              |                 |
      #            Today            Confirm

      let(:thursday) { Date.new(2015, 11, 19) }
      let(:monday) { Date.new(2015, 11, 23) }
      let(:wednesday) { Date.new(2015, 11, 25) }

      before do
        allow(Rails.configuration).to receive(:holidays).
          and_return([monday])
      end

      it 'skips the public holiday' do
        expect(subject.confirm_by(thursday)).to eq(wednesday)
      end
    end
  end
end
