require 'rails_helper'

RSpec.describe Prison::VisitsController, type: :controller do
  let(:visit) {
    create(:visit)
  }

  it 'renders the edit template when the submission is invalid' do
    put :update, id: visit.id, booking_response: { selection: 'slot_0' }
    expect(response).to render_template('edit')
  end
end
