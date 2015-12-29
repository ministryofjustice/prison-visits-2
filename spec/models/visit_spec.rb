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

  describe 'state' do
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

    it 'is withdrawn after cancellation if not accpeted' do
      subject.cancel!
      expect(subject).to be_withdrawn
    end

    it 'is cancelled after cancellation if accepted' do
      subject.accept!
      subject.cancel!
      expect(subject).to be_cancelled
    end

    it 'is not processable after booking' do
      subject.accept!
      expect(subject).not_to be_processable
    end

    it 'is not processable after rejection' do
      subject.reject!
      expect(subject).not_to be_processable
    end

    it 'is not processable after withdrawal' do
      subject.cancel!
      expect(subject).not_to be_processable
    end

    it 'is not processable after cancellation' do
      subject.accept!
      subject.cancel!
      expect(subject).not_to be_processable
    end

    context 'transition time' do
      before do
        allow(subject).to receive(:created_at).and_return(Time.new(2015, 11, 28, 12, 00, 00).utc)
      end
      let(:time) { Time.new(2015, 12, 01, 12, 00, 00).utc }

      around do |example|
        travel_to(time) do
          example.run
        end
      end

      it 'is recorded after accepting' do
        expect { subject.accept! }.to change { subject.accepted_at }.
          from(nil).to(time)
      end

      it 'memoizes the number of seconds it took to accept' do
        expect { subject.accept! }.to change { subject.seconds_to_process }.
          from(nil).to(259_200)
      end

      it 'is recorded after rejection' do
        expect { subject.reject! }.to change { subject.rejected_at }.
          from(nil).to(time)
      end

      it 'memoizes the number of seconds it took to reject' do
        expect { subject.reject! }.to change { subject.seconds_to_process }.
          from(nil).to(259_200)
      end

      it 'is recorded after withdrawal' do
        expect { subject.cancel! }.to change { subject.withdrawn_at }.
          from(nil).to(time)
      end

      it 'memoizes the number of seconds it took to withdraw' do
        expect { subject.cancel! }.to change { subject.seconds_to_process }.
          from(nil).to(259_200)
      end

      it 'is recorded after cancellation' do
        subject.accept!
        subject.reload
        expect { subject.cancel! }.
          to change { subject.cancelled_at }.from(nil).to(time)
      end

      it 'memoizes the number of seconds it took to cancel' do
        subject.accept! # This sets days_to_process = 3.0
        subject.reload
        travel_to 3.days.from_now do # Assume they don't cancel straight away.
          expect { subject.cancel! }.to change { subject.seconds_to_process }.
            # Can work out difference between acceptance and cancellation using
            # accepted_at and cancelled_at columns if we need it.
            from(259_200).to(518_400)
        end
      end
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
