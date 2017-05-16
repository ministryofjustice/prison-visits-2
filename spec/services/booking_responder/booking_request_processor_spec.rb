require "rails_helper"

RSpec.describe BookingResponder::BookingRequestProcessor do
  include_context 'staff response setup'

  let(:staff_response) { StaffResponse.new(visit: visit, user: create(:user)) }
  let(:message)          { build(:message, body: 'A staff message') }
  before do
    visit.assign_attributes(params)
    expect(staff_response).to be_valid
  end

  subject { described_class.new(staff_response) }

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

    expect(visit.last_visit_state.processed_by).to eq(staff_response.user)
  end
end
