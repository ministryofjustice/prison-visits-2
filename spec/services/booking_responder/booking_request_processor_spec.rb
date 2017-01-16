# frozen_string_literal: true
require "rails_helper"

RSpec.describe BookingResponder::BookingRequestProcessor do
  include_context 'booking response setup'

  let(:booking_response) { BookingResponse.new(visit: visit, user: create(:user)) }
  let(:message)          { build(:message, body: 'A staff message') }
  before do
    visit.assign_attributes(params)
    expect(booking_response).to be_valid
  end

  subject { described_class.new(booking_response) }

  it '#process_request' do
    expect {
      subject.process_request message do
        visit.accept!
      end
    }.to change {
      visit.reload.processing_state
    }.from('requested').to('booked').and change {
      visit.messages.find_by(body: message.body)
    }.from(nil).to(message)

    expect(visit.last_visit_state.processed_by).to eq(booking_response.user)
  end
end
