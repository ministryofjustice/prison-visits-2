require 'rails_helper'

RSpec.describe Visit, type: :model do
  subject { build(:visit) }

  describe 'states' do
    it 'is requested initially' do
      expect(subject).to be_requested
    end

    it 'is booked after accepting' do
      subject.accept!
      expect(subject).to be_booked
    end

    it 'is rejected after rejecting' do
      subject.reject!
      expect(subject).to be_rejected
    end
  end

  describe 'prisoner_age' do
    it 'calculates age' do
      subject.prisoner_date_of_birth = Date.new(1995, 10, 8)
      expect(subject.prisoner_age).to eq(20)
    end
  end

  describe 'prisoner_full_name' do
    it 'joins first and last name' do
      subject.prisoner_first_name = 'Oscar'
      subject.prisoner_last_name = 'Wilde'
      expect(subject.prisoner_full_name).to eq('Oscar Wilde')
    end
  end

  describe 'visitor_age' do
    it 'calculates age' do
      subject.visitor_date_of_birth = Date.new(1995, 10, 8)
      expect(subject.visitor_age).to eq(20)
    end
  end

  describe 'visitor_full_name' do
    it 'joins first and last name' do
      subject.visitor_first_name = 'Oscar'
      subject.visitor_last_name = 'Wilde'
      expect(subject.visitor_full_name).to eq('Oscar Wilde')
    end
  end

  describe 'slots' do
    it 'lists only slots that are present' do
      subject.slot_option_0 = '2015-11-06T16:00/17:00'
      subject.slot_option_1 = ''
      subject.slot_option_2 = nil
      expect(subject.slots.length).to eq(1)
    end

    it 'converts each slot string to a ConcreteSlot' do
      subject.slot_option_0 = '2015-11-06T16:00/17:00'
      subject.slot_option_1 = '2015-11-06T17:00/18:00'
      subject.slot_option_2 = '2015-11-06T18:00/19:00'
      expect(subject.slots).to eq(
        [
          ConcreteSlot.new(2015, 11, 6, 16, 0, 17, 0),
          ConcreteSlot.new(2015, 11, 6, 17, 0, 18, 0),
          ConcreteSlot.new(2015, 11, 6, 18, 0, 19, 0)
        ]
      )
    end
  end

  describe 'slot_granted' do
    it 'returns a ConcreteSlot when set' do
      subject.slot_granted = '2015-11-06T16:00/17:00'
      expect(subject.slot_granted).
        to eq(ConcreteSlot.new(2015, 11, 6, 16, 0, 17, 0))
    end

    it 'returns nil when unset' do
      expect(subject.slot_granted).to be_nil
    end
  end

  describe 'slot_granted=' do
    it 'accepts a string' do
      subject.slot_granted = '2015-11-06T16:00/17:00'
      expect(subject.slot_granted).
        to eq(ConcreteSlot.new(2015, 11, 6, 16, 0, 17, 0))
    end

    it 'accepts a ConcreteSlot instance' do
      subject.slot_granted = ConcreteSlot.new(2015, 11, 6, 16, 0, 17, 0)
      expect(subject.slot_granted).
        to eq(ConcreteSlot.new(2015, 11, 6, 16, 0, 17, 0))
    end
  end
end
