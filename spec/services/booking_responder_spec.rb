require 'rails_helper'

RSpec.describe BookingResponder do
  subject { described_class.new(booking_response) }

  let(:visit) { create(:visit) }
  let(:booking_response) { BookingResponse.new(visit: visit) }

  context 'accepting a request' do
    before do
      visit.slot_option_1 = visit.prison.available_slots.to_a[1]
      visit.slot_option_2 = visit.prison.available_slots.to_a[2]
      booking_response.selection = 'slot_0'
      booking_response.reference_no = '1337807'
    end

    context 'with the first slot' do
      before do
        booking_response.selection = 'slot_0'
        subject.respond!
        visit.reload
      end

      it 'changes the status of the visit to booked' do
        expect(visit).to be_booked
      end

      it 'sets the reference number of the visit' do
        expect(visit.reference_no).to eq('1337807')
      end

      it 'assigns the selected slot' do
        expect(visit.slot_granted).to eq(visit.slots[0])
      end
    end

    context 'with the second slot' do
      before do
        booking_response.selection = 'slot_1'
        subject.respond!
        visit.reload
      end

      it 'assigns the selected slot' do
        expect(visit.slot_granted).to eq(visit.slots[1])
      end
    end

    context 'with the third slot' do
      before do
        booking_response.selection = 'slot_2'
        subject.respond!
        visit.reload
      end

      it 'assigns the selected slot' do
        expect(visit.slot_granted).to eq(visit.slots[2])
      end
    end
  end

  context 'rejecting a request' do
    context 'because no slot is available' do
      before do
        booking_response.selection = 'slot_unavailable'
        subject.respond!
      end

      it 'changes the status of the visit to rejected' do
        expect(visit).to be_rejected
      end
    end
  end
end
