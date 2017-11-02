require 'rails_helper'

RSpec.describe BookingResponder::Cancel do
  subject(:instance) { described_class.new(cancellation_response) }

  let(:cancellation_response) do
    CancellationResponse.new(visit: visit, user: user, reasons: [reason])
  end
  let(:visit) { FactoryBot.create(:booked_visit) }
  let(:reason) { 'booked_in_error' }

  let(:user) { FactoryBot.create(:user) }

  it 'cancels the visit and marks it as cancelled in nomis' do
    instance.process_request

    visit.reload
    expect(visit).to be_cancelled
    expect(visit.cancellation.reasons).to eq([reason])
    expect(visit.cancellation.nomis_cancelled).to eq(true)
  end
end
