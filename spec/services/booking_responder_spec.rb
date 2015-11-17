require 'rails_helper'

RSpec.describe BookingResponder do
  subject { described_class.new(booking_response) }

  let(:prison) { create(:prison) }
  let(:visit) { create(:visit_with_three_slots) }
  let(:booking_response) { BookingResponse.new(visit: visit) }

  let(:visit_after_responding) {
    subject.respond!
    visit.reload
  }

  context 'accepting a request' do
    before do
      booking_response.selection = 'slot_0'
      booking_response.reference_no = '1337807'
    end

    context 'with the first slot' do
      before do
        booking_response.selection = 'slot_0'
      end

      it 'changes the status of the visit.reload to booked' do
        expect(visit_after_responding).to be_booked
      end

      it 'sets the reference number of the visit' do
        expect(visit_after_responding.reference_no).to eq('1337807')
      end

      it 'assigns the selected slot' do
        expect(visit_after_responding.slot_granted).
          to eq(visit_after_responding.slots[0])
      end
    end

    context 'with the second slot' do
      before do
        booking_response.selection = 'slot_1'
      end

      it 'assigns the selected slot' do
        expect(visit_after_responding.slot_granted).
          to eq(visit_after_responding.slots[1])
      end
    end

    context 'with the third slot' do
      before do
        booking_response.selection = 'slot_2'
      end

      it 'assigns the selected slot' do
        expect(visit_after_responding.slot_granted).
          to eq(visit_after_responding.slots[2])
      end
    end
  end

  context 'rejecting a request' do
    context 'because no slot is available' do
      it 'changes the status of the visit to rejected' do
        booking_response.selection = 'slot_unavailable'
        expect(visit_after_responding).to be_rejected
      end
    end
  end
end
