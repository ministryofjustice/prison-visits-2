require 'rails_helper'

RSpec.describe BookingResponder do
  subject { described_class.new(staff_response, message:) }

  let(:visit)            { create(:visit_with_three_slots) }
  let(:staff_response)   { StaffResponse.new(visit:) }
  let(:message)          { nil }

  describe 'with a requested visit' do
    let(:accept_processor) { spy(BookingResponder::Accept) }
    let(:reject_processor) { spy(BookingResponder::Reject) }
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
      end

      it 'accepts the booking' do
        subject.respond!
        expect(accept_processor).to have_received(:process_request).with(message)
      end
    end

    context 'when a booking is not bookable' do
      before do
        visit.slot_granted = Rejection::SLOT_UNAVAILABLE

        expect(BookingResponder::Accept).not_to receive(:new)
        expect(BookingResponder::Reject).to receive(:new)
          .and_return(reject_processor)
      end

      it 'rejects the booking' do
        subject.respond!
        expect(reject_processor).to have_received(:process_request)
      end

      it 'sends the booked emails to prison and visitors' do
        subject.respond!
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
