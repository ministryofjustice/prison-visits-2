require 'rails_helper'

RSpec.describe CancellationResponse do
  subject(:instance) do
    described_class.new(visit: visit, user: user, reasons: [reason])
  end

  let(:user) { nil }
  let(:reason) { Cancellation::VISITOR_CANCELLED }
  let(:visit) { FactoryGirl.create(:booked_visit) }

  describe '#can_cancel?' do
    subject(:can_cancel?) { instance.can_cancel? }

    it 'uses the state machine on visit' do
      expect(visit).to receive(:can_cancel?).and_call_original
      expect(can_cancel?).to eq(true)
    end
  end

  describe '#cancel!' do
    it 'process the cancellation and enqueues the email' do
      expect_any_instance_of(BookingResponder::Cancel).to receive(:process_request)
      mail = double('mail')
      expect(VisitorMailer).to receive(:cancelled).with(visit).and_return(mail)
      expect(mail).to receive(:deliver_later)

      instance.cancel!
    end
  end
end
