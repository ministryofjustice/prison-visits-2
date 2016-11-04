require "rails_helper"

RSpec.describe BookingResponder::Reject do
  include_context 'booking response setup'

  before do
    params[:slot_granted] = visit.slot_option_0
    params[:rejection_attributes][:reasons] = [Rejection::NO_ALLOWANCE]

    visit.assign_attributes(params)
    booking_response.valid?
  end

  let(:booking_response) { BookingResponse.new(visit: visit) }

  subject { described_class.new(booking_response) }

  describe '#process_visit' do
    it 'process the visit' do
      expect {
        subject.process_request
      }.to change {
        visit.processing_state
      }.from('requested').to('rejected').and change {
        visit.closed
      }.to(nil).and change {
        visit.reference_no
      }.to(nil)
    end
  end
end
