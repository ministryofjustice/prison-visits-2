require 'rails_helper'

RSpec.describe BookingResponder do
  subject { described_class.new(staff_response, message: message) }

  let(:visit)            { create(:visit_with_three_slots) }
  let(:staff_response)   { StaffResponse.new(visit: visit) }
  let(:message)          { nil }

  describe 'with a requested visit' do
    let(:accept_processor) { spy(BookingResponder::Accept) }
    let(:reject_processor) { spy(BookingResponder::Reject) }
    let(:visitor_mailer)   { spy(VisitorMailer) }
    let(:message)          do
      Message.new(body: 'a cheeky message from staff')
    end
    let(:message_attributes) { message.attributes.slice('id', 'body') }

    context 'when a booking is bookable' do
      before do
        visit.slot_granted = visit.slot_option_0

        expect(BookingResponder::Accept)
          .to receive(:new)
          .with(instance_of(StaffResponse))
          .and_return(accept_processor)
        allow(VisitorMailer).to receive(:booked)
          .and_return(visitor_mailer)
      end

      it 'accepts the booking' do
        subject.respond!
        expect(accept_processor).to have_received(:process_request).with(message)
      end

      it 'sends the booked emails to prison and visitors' do
        subject.respond!
        expect(VisitorMailer).to have_received(:booked)
          .with(staff_response.email_attrs, message_attributes)
      end
    end

    context 'when a booking is not bookable' do
      before do
        visit.slot_granted = Rejection::SLOT_UNAVAILABLE

        expect(BookingResponder::Accept).not_to receive(:new)
        expect(BookingResponder::Reject).to receive(:new)
          .and_return(reject_processor)
        allow(VisitorMailer).to receive(:rejected)
          .and_return(visitor_mailer)
      end

      it 'rejects the booking' do
        subject.respond!
        expect(reject_processor).to have_received(:process_request)
      end

      it 'sends the booked emails to prison and visitors' do
        subject.respond!
        expect(VisitorMailer).to have_received(:rejected)
          .with(staff_response.email_attrs, message_attributes)
      end
    end
  end

  describe 'with a withdrawn visit' do
    before do
      visit.withdraw!
    end

    it 'does not call any processor' do
      expect(BookingResponder::Accept).not_to receive(:new).with(any_args)
      expect(BookingResponder::Reject).not_to receive(:new).with(any_args)
      subject.respond!
    end
  end
end
