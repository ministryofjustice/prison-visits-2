require 'rails_helper'

RSpec.describe Visit, type: :model do
  subject { build(:visit) }

  describe '.delivery_error_type' do
    specify do
      is_expected.
        to validate_inclusion_of(:delivery_error_type).
        in_array(%w[ bounced spam_reported ])
    end

    it { is_expected.to allow_value(nil).for(:delivery_error_type) }
    it { is_expected.to allow_value('').for(:delivery_error_type) }
  end

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

  describe 'confirm_by' do
    let(:prison) { instance_double(Prison) }
    let(:confirmation_date) { Date.new(2015, 11, 1) }

    it 'asks its prison for the confirmation date based on booking creation' do
      allow(subject).to receive(:created_at).
        and_return(Time.zone.local(2015, 10, 7, 14, 49))
      allow(subject).to receive(:prison).
        and_return(prison)

      expect(prison).to receive(:confirm_by).
        with(Date.new(2015, 10, 7)).
        and_return(confirmation_date)
      expect(subject.confirm_by).to eq(confirmation_date)
    end
  end
end
