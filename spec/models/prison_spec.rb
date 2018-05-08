require 'rails_helper'

RSpec.describe Prison, type: :model do
  before do
    subject.lead_days = 3
    subject.weekend_processing = false
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:booking_window).is_less_than_or_equal_to(PrisonSeeder::SeedEntry::DEFAULT_BOOKING_WINDOW) }
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

  context 'with available slots and bookability' do
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
      context "when a prison doesn't process at the weekend" do
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
        allow(Rails.configuration.calendar).
          to receive(:business_day?).and_call_original

        expect(Rails.configuration.calendar).
          to receive(:business_day?).with(monday).and_return(false)
      end

      it 'skips the public holiday' do
        expect(subject.confirm_by(thursday)).to eq(wednesday)
      end
    end
  end

  describe 'slot_details=' do
    context 'when a day name is invalid' do
      it 'raises an exception' do
        expect {
          subject.slot_details = {
            'recurring' => { 'xxx' => ['1330-1430'] }
          }
        }.to raise_exception(ArgumentError)
      end
    end

    context 'when an anomalous slot is invalid' do
      it 'raises an exception' do
        expect {
          subject.slot_details = {
            'anomalous' => { '2020-01-01' => ['2630-2730'] }
          }
        }.to raise_exception(ArgumentError)
      end
    end

    context 'when an unbookable day is invalid' do
      it 'raises an exception' do
        expect {
          subject.slot_details = {
            'unbookable' => ['9999-99-99']
          }
        }.to raise_exception(ArgumentError)
      end
    end
  end

  describe 'validation' do
    context 'when there is a duplicate unbookable date' do
      it 'does not have valid slot_details' do
        subject.slot_details = {
          'unbookable' => ['2020-01-02', '2020-01-02']
        }

        subject.validate
        expect(subject.errors).to have_key(:slot_details)
      end
    end

    context 'when an unbookable date conflicts with an anomalous date' do
      it 'does not have valid slot_details' do
        subject.slot_details = {
          'unbookable' => ['2020-01-02'],
          'anomalous' => { '2020-01-02' => ['0900-1000'] }
        }

        subject.validate
        expect(subject.errors).to have_key(:slot_details)
      end
    end
  end

  describe 'translation' do
    before do
      I18n.locale = 'cy'
    end

    context 'when the prison has no translations for the current locale' do
      it 'returns the name field' do
        subject.name = 'NAME'
        expect(subject.name).to eq('NAME')
      end

      it 'returns the address field' do
        subject.address = 'ADDRESS'
        expect(subject.address).to eq('ADDRESS')
      end
    end

    context 'when the prison has translations for the current locale' do
      it 'returns the localised name' do
        subject.name = 'NAME'
        subject.translations = {
          'cy' => { 'name' => 'XXXX' }
        }
        expect(subject.name).to eq('XXXX')
      end

      it 'returns the localised address' do
        subject.address = 'ADDRESS'
        subject.translations = {
          'cy' => { 'address' => 'XXXXXXX' }
        }
        expect(subject.address).to eq('XXXXXXX')
      end
    end
  end

  describe '.validate_visitor_ages_on' do
    context "when there aren't any visitors" do
      let(:target) { double('target').as_null_object }
      let(:group) { [] }

      it 'skips the vaildation silently' do
        expect{
          subject.validate_visitor_ages_on(target, 'adults', group)
        }.not_to raise_error
      end
    end

    context 'when the visit is requested by someone under 18' do
      let(:target) { double('target').as_null_object }
      let(:group) { [12, 15, 18] }

      before do
        allow(subject).to receive(:adult?).and_return(false, false, true)
      end

      it 'makes the request invalid' do
        expect(target.errors).to receive(:add).with('adults', :lead_visitor_age, min: 18)
        subject.validate_visitor_ages_on(target, 'adults', group)
      end
    end

    context 'when the visit is requested by someone over 18' do
      let(:target) { double('target').as_null_object }
      let(:group) { [18, 15, 18] }

      before do
        allow(subject).to receive(:adult?).and_return(true, false, true)
      end

      it 'makes the request invalid' do
        expect(target.errors).not_to receive(:add).with('adults', :lead_visitor_age)
        subject.validate_visitor_ages_on(target, 'adults', group)
      end
    end
  end
end
