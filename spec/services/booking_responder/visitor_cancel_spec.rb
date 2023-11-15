require 'rails_helper'

RSpec.describe BookingResponder::VisitorCancel do
  subject(:instance) { described_class.new(visitor_cancellation_response) }

  let(:visitor_cancellation_response) do
    VisitorCancellationResponse.new(visit:)
  end
  let(:visit) { FactoryBot.create(:booked_visit) }
  let(:reason) { Cancellation::VISITOR_CANCELLED }

  it 'cancels the visit and marks it as not cancelled in nomis' do
    instance.process_request

    visit.reload
    expect(visit).to be_cancelled
    expect(visit.cancellation.reasons).to eq([reason])
    expect(visit.cancellation.nomis_cancelled).to eq(false)
  end
end
