require 'rails_helper'

RSpec.describe VisitorCancellationResponse do
  subject(:instance) { described_class.new(visit: visit) }

  let(:visit) { create(:booked_visit) }

  describe '#visitor_can_cancel?' do
    subject(:visitor_can_cancel?) { instance.visitor_can_cancel? }

    context "when it can't be withdrawn" do
      let(:visit) { create(:withdrawn_visit) }

      it { is_expected.to eq(false) }
    end

    context 'when the visit is booked' do
      context 'when this has not yet started' do
        let(:prison) { FactoryBot.create(:prison) }
        let(:visit) do
          FactoryBot.create(:booked_visit,
            prison: prison,
            slot_granted: prison.available_slots.first)
        end

        it { is_expected.to eq(true) }
      end

      context 'when it has already started' do
        let(:visit) do
          create(
            :booked_visit,
            slot_granted: ConcreteSlot.new(2015, 11, 6, 16, 0, 17, 0))
        end

        it { is_expected.to eq(false) }
      end
    end
  end

  describe '#cancel!' do
    it 'process the cancellation' do
      expect_any_instance_of(BookingResponder::VisitorCancel).to receive(:process_request)

      instance.cancel!
    end
  end
end
