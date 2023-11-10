require "rails_helper"

RSpec.describe Prison::EmailPreviewsController do
  describe 'with an invalid staff response' do
    let(:visit) { create(:visit) }
    let(:errors) { double(ActiveModel::Errors, full_messages: ['invalid booking response']) }
    let(:staff_response) { double(StaffResponse, 'valid?': false, errors:) }

    before do
      login_user(create(:user), current_estates: [visit.prison.estate])
      expect(StaffResponse).to receive(:new).and_return(staff_response)
    end

    it 'renders the errors message' do
      put :update, params: { visit_id: visit.id, visit: visit.attributes, locale: 'en' }
      expect(response.body).to include('invalid booking response')
    end
  end
end
