require 'rails_helper'

RSpec.describe BookingResponder::Cancel do
  subject(:instance) { described_class.new(cancellation_response, options) }

  let(:cancellation_response) do
    CancellationResponse.new(visit, reasons: reasons)
  end
  let(:nomis_id)             { nil }
  let(:visit)                { create(:booked_visit, nomis_id: nomis_id) }
  let(:reasons)              { [Cancellation::BOOKED_IN_ERROR] }
  let(:user)                 { create(:user) }
  let(:booking_response)     { BookingResponse.successful  }
  let(:options)              { {} }

  before do
    expect(cancellation_response).to be_valid
  end

  it 'cancels the visit and marks it as manually cancelled ' do
    instance.process_request

    visit.reload
    expect(visit).to be_cancelled
    expect(visit.cancellation.reasons).to eq(reasons)
  end
end
