require 'rails_helper'

RSpec.describe DateHelper do
  describe 'format_date_of_birth' do
    it 'formats a date from a date' do
      expect(helper.format_date_of_birth(Date.parse('2014-07-24')))
        .to eq('24 July 2014')
    end
  end

  describe 'format_date_without_year' do
    it 'formats a day from a date' do
      expect(helper.format_date_without_year(Date.parse('2014-07-24')))
        .to eq('Thursday 24 July')
    end
  end

  describe 'format_slot_begin_time_for_public' do
    let(:slot) {
      ConcreteSlot.new(2015, 11, 5, 13, 30, 14, 45)
    }

    it 'displays the date and the time of a slot' do
      expect(helper.format_slot_begin_time_for_public(slot))
        .to eq('Thursday 5 November 1:30pm')
    end
  end

  describe 'format_slot_for_public' do
    let(:slot) {
      ConcreteSlot.new(2015, 11, 5, 13, 30, 14, 45)
    }

    it 'displays the date and the time and duration of a slot' do
      expect(helper.format_slot_for_public(slot))
        .to eq('Thursday 5 November 1:30pm for 1 hr 15 mins')
    end
  end

  describe 'format_slot_for_staff' do
    let(:slot) {
      ConcreteSlot.new(2015, 11, 5, 13, 30, 14, 45)
    }

    it 'displays the date and the time of a slot' do
      expect(helper.format_slot_for_staff(slot))
        .to eq('Thursday 05/11/2015 13:30 - 14:45')
    end
  end

  describe 'format_slot_times' do
    let(:slot) {
      ConcreteSlot.new(2015, 11, 5, 13, 30, 14, 45)
    }

    it 'displays the date the times of a slot' do
      expect(helper.format_slot_times(slot)).to eq('13:30–14:45')
    end
  end

  describe '#format_visit_slot_date_for_staff' do
    subject { helper.format_visit_slot_date_for_staff(visit) }

    let(:preferred_slot) { ConcreteSlot.new(2016, 7, 19, 10, 30, 11, 30) }
    let(:visit) do
      FactoryBot.build_stubbed(:visit,
                               slot_option_0: preferred_slot,
                               slot_granted: slot_granted)
    end

    context 'with no slot granted' do
      let(:slot_granted) { nil }

      it 'formats the preferred slot' do
        expect(subject).to eq(preferred_slot.to_date.to_fs(:short_nomis))
      end
    end

    context 'with a granted slot' do
      let(:slot_granted) { ConcreteSlot.new(2015, 11, 5, 13, 30, 14, 45) }

      it 'formats the granted slot' do
        expect(subject).to eq(slot_granted.to_date.to_fs(:short_nomis))
      end
    end
  end

  describe '#format_visit_slot_times_for_staff' do
    subject { helper.format_visit_slot_times_for_staff(visit) }

    let(:preferred_slot) { ConcreteSlot.new(2016, 7, 19, 10, 30, 11, 30) }
    let(:visit) do
      FactoryBot.build_stubbed(:visit,
                               slot_option_0: preferred_slot,
                               slot_granted: slot_granted)
    end

    context 'with no slot granted' do
      let(:slot_granted) { nil }

      it 'formats the preferred slot' do
        expect(subject).to eq(helper.format_slot_times(preferred_slot))
      end
    end

    context 'with a granted slot' do
      let(:slot_granted) { ConcreteSlot.new(2015, 11, 5, 13, 30, 14, 45) }

      it 'formats the granted slot' do
        expect(subject).to eq(helper.format_slot_times(slot_granted))
      end
    end
  end
end
