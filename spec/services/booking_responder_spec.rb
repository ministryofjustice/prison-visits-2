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

  let(:mailing) {
    double(Mail::Message, deliver_later: nil)
  }

  before do
    allow(VisitorMailer).to receive(:booked).and_return(mailing)
    allow(PrisonMailer).to receive(:booked).and_return(mailing)
    allow(VisitorMailer).to receive(:rejected).and_return(mailing)
    allow(PrisonMailer).to receive(:rejected).and_return(mailing)
  end

  context 'accepting a request' do
    before do
      booking_response.selection = 'slot_0'
      booking_response.reference_no = '1337807'
    end

    it 'changes the status of the visit to booked' do
      expect(visit_after_responding).to be_booked
    end

    it 'sets the reference number of the visit' do
      expect(visit_after_responding.reference_no).to eq('1337807')
    end

    it 'marks the visit as closed' do
      booking_response.closed_visit = true
      expect(visit_after_responding).to be_closed
    end

    it 'marks the visit as not closed' do
      booking_response.closed_visit = false
      expect(visit_after_responding).not_to be_closed
    end

    it 'emails the visitor' do
      expect(VisitorMailer).to receive(:booked).with(visit).
        and_return(mailing)
      expect(mailing).to receive(:deliver_later)
      subject.respond!
    end

    it 'emails the prison' do
      expect(PrisonMailer).to receive(:booked).with(visit).
        and_return(mailing)
      expect(mailing).to receive(:deliver_later)
      subject.respond!
    end

    context 'with the first slot' do
      before do
        booking_response.selection = 'slot_0'
      end

      it 'assigns the selected slot' do
        expect(visit_after_responding.slot_granted).
          to eq(visit_after_responding.slots[0])
      end

      it 'logs the booking_response' do
        subject.respond!
        expect(LogStasher.request_context).to match(booking_response: 'booked')
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

      it 'logs the booking_response' do
        subject.respond!
        expect(LogStasher.request_context).to match(booking_response: 'booked')
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

      it 'logs the booking_response' do
        subject.respond!
        expect(LogStasher.request_context).to match(booking_response: 'booked')
      end
    end
  end

  context 'rejecting a request' do
    before do
      booking_response.selection = 'slot_unavailable'
    end

    it 'emails the visitor' do
      expect(VisitorMailer).to receive(:rejected).with(visit).
        and_return(mailing)
      expect(mailing).to receive(:deliver_later)
      subject.respond!
    end

    it 'emails the prison' do
      expect(PrisonMailer).to receive(:rejected).with(visit).
        and_return(mailing)
      expect(mailing).to receive(:deliver_later)
      subject.respond!
    end

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

      it 'logs the booking_response' do
        subject.respond!
        expect(LogStasher.request_context).to match(booking_response: 'rejected')
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

      it 'logs the booking_response' do
        subject.respond!
        expect(LogStasher.request_context).to match(booking_response: 'rejected')
      end

      context 'when VO will be renewed' do
        let(:allowance_date) { Time.zone.today + 7 }

        before do
          booking_response.allowance_will_renew = true
          booking_response.allowance_renews_on = allowance_date
        end

        it 'sets the rejection VO renewal date' do
          expect(visit_after_responding.rejection.allowance_renews_on).
            to eq(allowance_date)
        end

        context 'and PVO is possible' do
          let(:privileged_allowance_date) { Time.zone.today + 7 }

          before do
            booking_response.privileged_allowance_available = true
            booking_response.privileged_allowance_expires_on = privileged_allowance_date
          end

          it 'sets the rejection PVO expiry date' do
            expect(visit_after_responding.rejection.privileged_allowance_expires_on).
              to eq(privileged_allowance_date)
          end

          it 'logs the booking_response' do
            subject.respond!
            expect(LogStasher.request_context).to match(booking_response: 'rejected')
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

      it 'logs the booking_response' do
        subject.respond!
        expect(LogStasher.request_context).to match(booking_response: 'rejected')
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

      it 'logs the booking_response' do
        subject.respond!
        expect(LogStasher.request_context).to match(booking_response: 'rejected')
      end
    end

    context 'because the visitor is not on the list' do
      before do
        booking_response.selection = 'visitor_not_on_list'
        visit.visitors << build(:visitor)
        booking_response.unlisted_visitor_ids = [visit.visitors.first.id]
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

      it 'marks each unlisted visitor as not_on_list' do
        subject.respond!
        expect(visit.visitors[0]).to be_not_on_list
        expect(visit.visitors[1]).not_to be_not_on_list
      end

      it 'logs the booking_response' do
        subject.respond!
        expect(LogStasher.request_context).to match(booking_response: 'rejected')
      end
    end

    context 'because the visitor is banned' do
      before do
        booking_response.selection = 'visitor_banned'
        visit.visitors << build(:visitor)
        booking_response.banned_visitor_ids = [visit.visitors.first.id]
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

      it 'marks each unlisted visitor as not_on_list' do
        subject.respond!
        expect(visit.visitors[0]).to be_banned
        expect(visit.visitors[1]).not_to be_banned
      end

      it 'logs the booking_response' do
        subject.respond!
        expect(LogStasher.request_context).to match(booking_response: 'rejected')
      end
    end
  end
end
