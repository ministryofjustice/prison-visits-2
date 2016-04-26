require 'rails_helper'

RSpec.describe DateHelper do
  describe 'format_date_of_birth' do
    it 'formats a date from a date' do
      expect(helper.format_date_of_birth(Date.parse('2014-07-24'))).
        to eq('24 July 2014')
    end
  end

  describe 'format_date_without_year' do
    it 'formats a day from a date' do
      expect(helper.format_date_without_year(Date.parse('2014-07-24'))).
        to eq('Thursday 24 July')
    end
  end

  describe 'format_slot_begin_time_for_public' do
    let(:slot) {
      ConcreteSlot.new(2015, 11, 5, 13, 30, 14, 45)
    }

    it 'displays the date and the time of a slot' do
      expect(helper.format_slot_begin_time_for_public(slot)).
        to eq('Thursday 5 November 1:30pm')
    end
  end

  describe 'format_slot_for_public' do
    let(:slot) {
      ConcreteSlot.new(2015, 11, 5, 13, 30, 14, 45)
    }

    it 'displays the date and the time and duration of a slot' do
      expect(helper.format_slot_for_public(slot)).
        to eq('Thursday 5 November 1:30pm for 1 hr 15 mins')
    end
  end

  describe 'format_slot_for_staff' do
    let(:slot) {
      ConcreteSlot.new(2015, 11, 5, 13, 30, 14, 45)
    }

    it 'displays the date and the time of a slot' do
      expect(helper.format_slot_for_staff(slot)).
        to eq('05/11/2015 13:30 - 14:45')
    end
  end
end
