require "rails_helper"

RSpec.describe BookingResponder::BookingRequestProcessor do
  include_context 'booking request processor setup'

  it '#process_request' do
    expect {
      subject.process_request { visit.accept! }
    }.to change {
      unlisted_visitors.map(&:reload).map(&:not_on_list)
    }.from([false] * 2).to([true] * 2).and change {
      banned_visitors.map(&:reload).map(&:banned)
    }.from([false] * 2).to([true] * 2).and change {
      visit.processing_state
    }.from('requested').to('booked').and change {
      visit.messages.where(body: params[:message_body]).count
    }.by(1)
  end
end
