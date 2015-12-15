require 'rails_helper'

RSpec.describe Prison::VisitsController, type: :controller do
  let(:visit) {
    create(:visit)
  }

  it 'renders the show template when the submission is invalid' do
    put :update, id: visit.id, booking_response: { selection: 'slot_0' }
    expect(response).to render_template('show')
  end
end
