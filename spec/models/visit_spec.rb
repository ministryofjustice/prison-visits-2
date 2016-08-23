require 'rails_helper'

RSpec.describe Visit, type: :model do
  subject { build(:visit) }

  let(:mailing) {
    double(Mail::Message, deliver_later: nil)
  }

  describe 'scopes' do
    describe '.from_estate' do
      let(:visit) do
        FactoryGirl.create(:visit)
      end

      let!(:estate) { visit.prison.estate }

      before do
        FactoryGirl.create(:visit)
      end

      subject { described_class.from_estate(estate) }

      it { is_expected.to eq([visit]) }
    end
  end

  describe "#confirm_nomis_cancelled" do
    let(:cancellation) do
      FactoryGirl.create(:cancellation,
        nomis_cancelled: nomis_cancelled,
        updated_at: 1.day.ago)
    end
    let(:visit) { cancellation.visit }

    subject(:confirm_nomis_cancelled) { visit.confirm_nomis_cancelled }

    context "when it hasn't been marked as cancelled" do
      let(:nomis_cancelled) { false }

      it 'marks the cancellation as cancelled in nomis' do
        confirm_nomis_cancelled
        expect(cancellation.reload).to be_nomis_cancelled
      end

      it 'bumps updated_at field' do
        expect { confirm_nomis_cancelled }.
          to change { cancellation.reload.updated_at }
      end
    end

    context 'when it has already been cancelled' do
      let(:nomis_cancelled) { true }

      it 'does not bump updated_at field' do
        expect { confirm_nomis_cancelled }.
          to_not change { cancellation.reload.updated_at }
      end
    end
  end

  describe "#staff_cancellation!" do
    let(:visit) { FactoryGirl.create(:booked_visit) }
    let(:reason) { Cancellation::REASONS.first }

    subject(:cancellation!) { visit.staff_cancellation!(reason) }

    it 'transitions to cancelled' do
      expect { cancellation! }.
        to change { visit.processing_state }.to('cancelled')
    end

    it 'creates a cancellation record' do
      expect { cancellation! }.
        to change {
          Cancellation.where(visit_id: visit.id, nomis_cancelled: true).count
        }.by(1)
    end

    it 'sends an email to the visitor' do
      expect(VisitorMailer).to receive(:cancelled).with(visit).and_return(mailing)
      cancellation!
    end

    context 'invalid reason' do
      let(:reason) { 'rubbish' }
      it 'fails and does not record the cancellation' do
        expect { cancellation! }.to raise_error(ActiveRecord::RecordInvalid)
        expect(Cancellation.count).to eq(0)
        expect(visit.reload.processing_state).to eq('booked')
      end
    end
  end

  describe '#can_cancel_or_withdraw?' do
    subject { visit.can_cancel_or_withdraw? }

    context 'when it can be withdrawn' do
      let(:visit) { FactoryGirl.create(:visit) }
      it { is_expected.to eq(true) }
    end

    context 'when it can be cancelled' do
      let(:visit) { FactoryGirl.create(:booked_visit) }
      it { is_expected.to eq(true) }
    end

    context "when it can't be cancelled or withdrawn" do
      let(:visit) { FactoryGirl.create(:withdrawn_visit) }
      it { is_expected.to eq(false) }
    end
  end

  describe '#visitor_cancel_or_withdraw!' do
    subject { visit.visitor_cancel_or_withdraw! }

    context "when it can't be cancelled or withdrawn" do
      let(:visit) { FactoryGirl.create(:withdrawn_visit) }
      it { expect { subject }.to raise_error(/cancel or withdraw/) }
    end

    context 'when it can be withdrawn' do
      let(:visit) { FactoryGirl.create(:visit) }

      it 'transitions to withdrawn' do
        expect { subject }.
          to change { visit.processing_state }.to('withdrawn')
      end
    end

    context 'when it can be cancelled' do
      let(:visit) { FactoryGirl.create(:booked_visit) }

      it 'transitions to cancelled' do
        expect { subject }.to change { visit.processing_state }.to('cancelled')
      end

      it 'creates a cancellation record' do
        expect { subject }.
          to change {
            Cancellation.where(visit_id: visit.id, nomis_cancelled: false).count
          }.by(1)
      end

      it 'sends an email to the prison' do
        expect(PrisonMailer).to receive(:cancelled).with(visit).and_return(mailing)
        subject
      end
    end
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
      subject.withdraw!
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
      subject.withdraw!
      expect(subject).not_to be_processable
    end

    it 'is not processable after cancellation' do
      subject.accept!
      subject.cancel!
      expect(subject).not_to be_processable
    end

    context '.visit_state_changes' do
      it { should have_many(:visit_state_changes) }

      it 'is recorded after accepting' do
        expect{
          subject.accept!
        }.to change {
          subject.visit_state_changes.booked.count
        }.by(1)
      end

      it 'is recorded after rejection' do
        expect{
          subject.reject!
        }.to change {
          subject.visit_state_changes.rejected.count
        }.by(1)
      end

      it 'is recorded after withdrawal' do
        expect{
          subject.withdraw!
        }.to change {
          subject.visit_state_changes.withdrawn.count
        }.by(1)
      end

      it 'is recorded after cancellation' do
        subject.accept!
        expect{
          subject.cancel!
        }.to change {
          subject.visit_state_changes.cancelled.count
        }.by(1)
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

  describe '#acceptance_message' do
    before do
      subject.accept!
    end

    context "when there isn't a message" do
      it { expect(subject.acceptance_message).to be_nil }
    end

    context "when there is a message" do
      let!(:message) do
        FactoryGirl.create(
          :message,
          visit: subject,
          visit_state_change: subject.visit_state_changes.last)
      end

      it { expect(subject.acceptance_message).to eq(message) }
    end
  end

  describe '#rejection_message' do
    before do
      subject.reject!
    end

    context "when there isn't a message" do
      it { expect(subject.rejection_message).to be_nil }
    end

    context "when there is a message" do
      let!(:message) do
        FactoryGirl.create(
          :message,
          visit: subject,
          visit_state_change: subject.visit_state_changes.last)
      end

      it { expect(subject.rejection_message).to eq(message) }
    end
  end
end
