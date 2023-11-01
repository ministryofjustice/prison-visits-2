require "rails_helper"

RSpec.describe BookingResponder::BookingRequestProcessor do
  include_context 'with staff response setup'

  let(:staff_response) { StaffResponse.new(visit: visit, user: create(:user)) }
  let(:message)        { build(:message, body: 'A staff message') }

  before do
    visit.assign_attributes(params)
    expect(staff_response).to be_valid
  end

  subject { described_class.new(staff_response) }

  describe '#process_request' do
    context 'when a happy path' do
      let(:process_request) do
        subject.process_request(message) do
          visit.rejection = nil
          visit.accept!
          BookingResponse.successful
        end
      end

      it 'persists the visit state change and message' do
        expect {
          process_request
        }.to change {
          visit.reload.processing_state
        }.from('requested').to('booked').and change {
          visit.messages.find_by(body: message.body)
        }.from(nil).to(message)

        expect(visit.last_visit_state.creator).to eq(staff_response.user)
      end

      it 'returns a sucessful booking response' do
        expect(process_request).to be_success
      end
    end

    context 'when a sad path' do
      let(:process_request) do
        subject.process_request(message) do
          visit.rejection = nil
          visit.accept!
          BookingResponse.new(errors: ['timeout'])
        end
      end

      it 'does not persist the visit state change and message' do
        expect { process_request }
          .not_to change { visit.reload.processing_state }

        expect(visit.messages.count).to eq(0)
        expect(visit.last_visit_state).to be_nil
      end

      it 'returns a sucesful booking response' do
        expect(process_request).not_to be_success
      end
    end
  end
end
