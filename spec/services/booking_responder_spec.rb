require 'rails_helper'

RSpec.describe BookingResponder do
  subject { described_class.new(booking_response, message) }

  let(:visit)            { create(:visit_with_three_slots) }
  let(:booking_response) { BookingResponse.new(visit: visit) }
  let(:message)          { nil }

  describe 'with a requested visit' do
    let(:accept_processor) { spy(BookingResponder::Accept) }
    let(:reject_processor) { spy(BookingResponder::Reject) }
    let(:visitor_mailer)   { spy(VisitorMailer) }
    let(:message)          do
      Message.new(body: 'a chicky message from staff')
    end
    let(:message_attributes) { message.attributes.slice('id', 'body') }

    context 'when a booking is bookable' do
      before do
        booking_response.visit.slot_granted = visit.slot_option_0
        expect(booking_response).to be_valid

        expect(BookingResponder::Accept).to receive(:new).
          and_return(accept_processor)
        allow(VisitorMailer).to receive(:booked).
          and_return(visitor_mailer)
      end

      it 'accepts the booking' do
        subject.respond!
        expect(accept_processor).to have_received(:process_request).with(message)
      end

      it 'sends the booked emails to prison and visitors' do
        subject.respond!
        expect(VisitorMailer).to have_received(:booked).
          with(booking_response.email_attrs, message_attributes)
      end
    end

    context 'when a booking is not bookable' do
      before do
        booking_response.visit.slot_granted = Rejection::SLOT_UNAVAILABLE
        expect(booking_response).to be_valid

        expect(BookingResponder::Accept).to_not receive(:new)
        expect(BookingResponder::Reject).to receive(:new).
          and_return(reject_processor)
        allow(VisitorMailer).to receive(:rejected).
          and_return(visitor_mailer)
      end

      it 'accepts the booking' do
        subject.respond!
        expect(reject_processor).to have_received(:process_request)
      end

      it 'sends the booked emails to prison and visitors' do
        subject.respond!
        expect(VisitorMailer).to have_received(:rejected).
          with(booking_response.email_attrs, message_attributes)
      end
    end
  end

  describe 'with a not requested visit' do
    before do
      visit.withdraw!
    end

    it 'does not call any processor' do
      expect(BookingResponder::Accept).to_not receive(:new).with(any_args)
      expect(BookingResponder::Reject).to_not receive(:new).with(any_args)
      subject.respond!
    end
  end
end
