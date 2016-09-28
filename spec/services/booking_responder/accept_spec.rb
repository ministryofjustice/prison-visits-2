require "rails_helper"

RSpec.describe BookingResponder::Accept do
  include_context 'booking request processor setup'

  before do
    params.merge!(
      reference_no: 1_337_807,
      closed_visit: [true, false].sample
    )
  end

  it 'process the request' do
    expect { subject.process_request }.to change {
      visit.reference_no
    }.from(nil).to('1337807').and change {
      visit.closed
    }.from(nil).to(params[:closed_visit]).and change {
      visit.slot_granted
    }.from(nil).
      to(booking_response.slot_granted).and change {
                                              visit.processing_state
                                            }.from('requested').to('booked')
  end
end
