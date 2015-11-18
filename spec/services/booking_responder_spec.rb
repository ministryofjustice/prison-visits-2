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

      it 'marks the visit as closed' do
        booking_response.closed_visit = true
        expect(visit_after_responding).to be_closed
      end

      it 'marks the visit as not closed' do
        booking_response.closed_visit = false
        expect(visit_after_responding).not_to be_closed
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
      before do
        booking_response.selection = 'slot_unavailable'
      end

      it 'changes the status of the visit to rejected' do
        expect(visit_after_responding).to be_rejected
      end

      it 'creates a rejection record' do
        expect(visit_after_responding.rejection).to be_a(Rejection)
      end

      it 'records the rejection reason' do
        expect(visit_after_responding.rejection.reason).
          to eq('slot_unavailable')
      end
    end

    context 'because the visitor has no more allowance' do
      before do
        booking_response.selection = 'no_allowance'
      end

      it 'changes the status of the visit to rejected' do
        expect(visit_after_responding).to be_rejected
      end

      it 'creates a rejection record' do
        expect(visit_after_responding.rejection).to be_a(Rejection)
      end

      it 'records the rejection reason' do
        expect(visit_after_responding.rejection.reason).
          to eq('no_allowance')
      end

      context 'when VO will be renewed' do
        let(:vo_date) { Time.zone.today + 7 }

        before do
          booking_response.vo_will_be_renewed = true
          booking_response.vo_renewed_on = vo_date
        end

        it 'sets the rejection VO renewal date' do
          expect(visit_after_responding.rejection.vo_renewed_on).
            to eq(vo_date)
        end

        context 'and PVO is possible' do
          let(:pvo_date) { Time.zone.today + 7 }

          before do
            booking_response.pvo_possible = true
            booking_response.pvo_expires_on = pvo_date
          end

          it 'sets the rejection PVO expiry date' do
            expect(visit_after_responding.rejection.pvo_expires_on).
              to eq(pvo_date)
          end
        end
      end
    end

    context 'because the prisoner details are incorrect' do
      before do
        booking_response.selection = 'prisoner_details_incorrect'
      end

      it 'changes the status of the visit to rejected' do
        expect(visit_after_responding).to be_rejected
      end

      it 'creates a rejection record' do
        expect(visit_after_responding.rejection).to be_a(Rejection)
      end

      it 'records the rejection reason' do
        expect(visit_after_responding.rejection.reason).
          to eq('prisoner_details_incorrect')
      end
    end

    context 'because the prisoner has moved' do
      before do
        booking_response.selection = 'prisoner_moved'
      end

      it 'changes the status of the visit to rejected' do
        expect(visit_after_responding).to be_rejected
      end

      it 'creates a rejection record' do
        expect(visit_after_responding.rejection).to be_a(Rejection)
      end

      it 'records the rejection reason' do
        expect(visit_after_responding.rejection.reason).
          to eq('prisoner_moved')
      end
    end

    context 'because the visitor is not on the list' do
      before do
        booking_response.selection = 'visitor_not_on_list'
      end

      it 'changes the status of the visit to rejected' do
        expect(visit_after_responding).to be_rejected
      end

      it 'creates a rejection record' do
        expect(visit_after_responding.rejection).to be_a(Rejection)
      end

      it 'records the rejection reason' do
        expect(visit_after_responding.rejection.reason).
          to eq('visitor_not_on_list')
      end
    end

    context 'because the visitor is banned' do
      before do
        booking_response.selection = 'visitor_banned'
      end

      it 'changes the status of the visit to rejected' do
        expect(visit_after_responding).to be_rejected
      end

      it 'creates a rejection record' do
        expect(visit_after_responding.rejection).to be_a(Rejection)
      end

      it 'records the rejection reason' do
        expect(visit_after_responding.rejection.reason).
          to eq('visitor_banned')
      end
    end
  end
end
