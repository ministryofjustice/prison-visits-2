require 'rails_helper'

RSpec.describe Prison::VisitsController, type: :controller do
  let(:visit) {
    create(:visit)
  }

  it 'renders the show template when the submission is invalid' do
    put :update,
      id: visit.id, booking_response: { selection: 'slot_0' }, locale: 'en'
    expect(response).to render_template('show')
  end

  context "whent the ip is not allowed" do
    before do
      allow_any_instance_of(ActionDispatch::Request).
        to receive(:remote_ip).
        and_return('192.168.1.0')
    end

    it 'raises a not found error' do
      expect {
        put :update, id: visit.id, locale: 'en'
      }.to raise_error(ActionController::RoutingError)
    end
  end
end
