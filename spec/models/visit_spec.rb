require 'rails_helper'

RSpec.describe Visit, type: :model do
  subject { build(:visit, visitors: [build(:visitor)]) }

  let(:mailing) do
    double(Mail::Message, deliver_later: nil)
  end

  it { is_expected.to have_one(:visit_order).dependent(:destroy) }

  describe 'transitions' do
    context 'when transitioning from requested to rejected' do
      it 'can not be saved without a rejection' do
        expect {
          subject.reject!
        }.to raise_error(StateMachines::InvalidTransition)
      end
    end
  end

  describe 'scopes' do
    describe '.from_estates' do
      let(:visit) do
        create(:visit)
      end
      let(:other_visit) do
        create(:visit)
      end

      let!(:estate) { visit.prison.estate }
      let!(:other_estate) { other_visit.prison.estate }

      before do
        create(:visit)
      end

      subject { described_class.from_estates([estate, other_estate]) }

      it { is_expected.to contain_exactly(visit, other_visit) }
    end
  end

  describe 'validations' do
    describe 'contact_phone_no' do
      before do
        subject.contact_phone_no = phone_no
      end

      context 'when the phone number is valid' do
        let(:phone_no) { '079 00 11 22 33' }

        it { is_expected.to be_valid }
      end

      context 'when the phone number is invalid' do
        let(:phone_no) { ' 07 00 11 22 33' }

        it { is_expected.not_to be_valid }
      end
    end
  end

  describe "#confirm_nomis_cancelled" do
    let(:cancellation) do
      FactoryBot.create(:cancellation,
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
        expect { confirm_nomis_cancelled }
          .to change { cancellation.reload.updated_at }
      end
    end

    context 'when it has already been cancelled' do
      let(:nomis_cancelled) { true }

      it 'does not bump updated_at field' do
        expect { confirm_nomis_cancelled }
          .not_to change { cancellation.reload.updated_at }
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
      reject_visit subject
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
      reject_visit subject
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

    context 'when .visit_state_changes' do
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
          reject_visit subject
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
      expect(subject.slot_granted)
        .to eq(ConcreteSlot.new(2015, 11, 6, 16, 0, 17, 0))
    end

    it 'returns nil when unset' do
      expect(subject.slot_granted).to be_nil
    end
  end

  describe 'slot_granted=' do
    it 'accepts a string' do
      subject.slot_granted = '2015-11-06T16:00/17:00'
      expect(subject.slot_granted)
        .to eq(ConcreteSlot.new(2015, 11, 6, 16, 0, 17, 0))
    end

    it 'accepts a ConcreteSlot instance' do
      subject.slot_granted = ConcreteSlot.new(2015, 11, 6, 16, 0, 17, 0)
      expect(subject.slot_granted)
        .to eq(ConcreteSlot.new(2015, 11, 6, 16, 0, 17, 0))
    end
  end

  describe 'confirm_by' do
    let(:prison) { instance_double(Prison) }
    let(:confirmation_date) { Date.new(2015, 11, 1) }

    it 'asks its prison for the confirmation date based on booking creation' do
      allow(subject).to receive(:created_at)
        .and_return(Time.zone.local(2015, 10, 7, 14, 49))
      allow(subject).to receive(:prison)
        .and_return(prison)

      expect(prison).to receive(:confirm_by)
        .with(Date.new(2015, 10, 7))
        .and_return(confirmation_date)
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

    context "when there is a message not owned by the visit" do
      before do
        FactoryBot.create(:message)
      end

      it { expect(subject.acceptance_message).to be_nil }
    end

    context "when there is a one off message" do
      before do
        FactoryBot.create(
          :message,
          visit: subject)
      end

      it { expect(subject.acceptance_message).to be_nil }
    end

    context "when there is an acceptance message" do
      let!(:message) do
        FactoryBot.create(
          :message,
          visit: subject,
          visit_state_change: subject.visit_state_changes.last)
      end

      it { expect(subject.acceptance_message).to eq(message) }
    end
  end

  describe '#rejection_message' do
    before do
      reject_visit subject
    end

    context "when there isn't a message" do
      it { expect(subject.rejection_message).to be_nil }
    end

    context "when there is a message not owned by the visit" do
      before do
        FactoryBot.create(:message)
      end

      it { expect(subject.acceptance_message).to be_nil }
    end

    context "when there is a one off message" do
      before do
        FactoryBot.create(:message, visit: subject)
      end

      it { expect(subject.acceptance_message).to be_nil }
    end

    context "when there is a rejection message" do
      let!(:message) do
        FactoryBot.create(
          :message,
          visit: subject,
          visit_state_change: subject.visit_state_changes.last)
      end

      it { expect(subject.rejection_message).to eq(message) }
    end
  end

  describe '#additional_visitors' do
    let(:visitor1) { FactoryBot.build_stubbed(:visitor) }
    let(:visitor2) { FactoryBot.build_stubbed(:visitor) }

    describe 'when there is one visitor' do
      before do
        subject.visitors = [visitor1]
      end

      it 'returns an empty list' do
        expect(subject.additional_visitors).to be_empty
      end
    end

    describe 'when there is more than one visitor' do
      before do
        subject.visitors = [visitor1, visitor2]
      end

      it 'returns a list without the principal visitor' do
        expect(subject.additional_visitors).to eq([visitor2])
      end
    end
  end

  describe '#allowed_additional_visitors' do
    let(:visitor1) { FactoryBot.build_stubbed(:visitor) }
    let(:visitor2) { FactoryBot.build_stubbed(:visitor) }
    let(:visitor3) { FactoryBot.build_stubbed(:visitor, banned: true) }

    describe 'when there is one visitor' do
      before do
        subject.visitors = [visitor1]
      end

      it 'returns an empty list' do
        expect(subject.allowed_additional_visitors).to be_empty
      end
    end

    describe 'when there is more than one visitor' do
      before do
        subject.visitors = [visitor1, visitor2, visitor3]
      end

      it 'returns a list without the principal visitor' do
        expect(subject.allowed_additional_visitors).to eq([visitor2])
      end
    end
  end
end
