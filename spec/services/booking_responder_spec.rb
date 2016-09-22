require 'rails_helper'
require_relative 'booking_responder_shared_context'

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
    include_context 'accepting a request'

    context 'when one of the visitors is not on the list' do
      include_context 'accepting a request'

      before do
        visit.visitors << build(:visitor)
        booking_response.unlisted_visitor_ids = [visit.visitors.first.id]
      end

      it 'marks each unlisted visitor as not_on_list' do
        subject.respond!
        expect(visit.visitors[0]).to be_not_on_list
        expect(visit.visitors[1]).not_to be_not_on_list
      end
    end

    context 'when one of the visitors is banned' do
      before do
        visit.visitors << build(:visitor)
        booking_response.banned_visitor_ids = [visit.visitors.first.id]
      end

      it 'marks each unlisted visitor as not_on_list' do
        subject.respond!
        expect(visit.visitors[0]).to be_banned
        expect(visit.visitors[1]).not_to be_banned
      end
    end

    context 'when staff have written a message' do
      before do
        booking_response.user = FactoryGirl.create(:user)
        booking_response.message_body = 'Bring proof of your identity'
      end

      it 'creates a message record for the visit' do
        expect { subject.respond! }.
          to change { visit.messages.count }.by(1)
        expect(Message.last.visit_state_change_id).to be_present
      end
    end
  end

  context 'rejecting a request' do
    before do
      booking_response.selection = 'slot_unavailable'
    end

    context 'when staff have written a message' do
      before do
        booking_response.user = FactoryGirl.create(:user)
        booking_response.message_body = 'Try next month'
      end

      it 'creates a message record for the visit' do
        expect { subject.respond! }.
          to change { visit.messages.count }.by(1)
        expect(Message.last.visit_state_change_id).to be_present
      end
    end

    context 'an already rejected visit' do
      before do
        subject.respond!
      end

      it 'does not try to re-reject the visit' do
        expect(VisitorMailer).to_not receive(:rejected)
        expect(PrisonMailer).to_not receive(:rejected)
        expect { subject.respond! }.to_not change { Rejection.count }
      end
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

    context 'because none of the visitors are on the list' do
      before do
        visit.visitors << build(:visitor)
        booking_response.unlisted_visitor_ids = visit.visitors.map(&:id)
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
        expect(visit.visitors[1]).to be_not_on_list
      end
    end

    context 'because the only visitor is banned' do
      before do
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

      it 'marks each banned visitor as banned' do
        subject.respond!
        expect(visit.visitors[0]).to be_banned
        expect(visit.visitors[1]).not_to be_banned
      end
    end
  end
end
