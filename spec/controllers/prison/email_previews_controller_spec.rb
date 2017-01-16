# frozen_string_literal: true
require "rails_helper"

RSpec.describe Prison::EmailPreviewsController do
  describe 'with an invalid booking response' do
    let(:visit) { create(:visit) }
    let(:errors) { double(ActiveModel::Errors, full_messages: ['invalid booking response']) }
    let(:booking_response) { double(BookingResponse, 'valid?': false, errors: errors) }

    before do
      login_user(create(:user), current_estates: [visit.prison.estate])
      expect(BookingResponse).to receive(:new).and_return(booking_response)
    end

    it 'renders the errors message' do
      put :update, { visit_id: visit.id, visit: visit.attributes }
      expect(response.body).to include('invalid booking response')
    end
  end
end
