require 'rails_helper'

RSpec.describe Api::SlotsController do
  let(:parsed_body) {
    JSON.parse(response.body)
  }

  render_views

  describe 'index' do
    let(:params) {
      {
        format: :json,
        prison_id: prison.id,
        prisoner_number: 'a1234bc',
        prisoner_dob: '1950-01-01'
      }
    }

    let(:prison) { create(:prison) }

    let(:slots) {
      [
        '2016-02-15T13:30/14:30',
        '2016-02-22T13:30/14:30',
        '2016-02-29T13:30/14:30'
      ].map { |e| ConcreteSlot.parse(e) }
    }

    let(:slot_availability) {
      instance_double(SlotAvailability, restrict_by_prisoner: nil, slots: slots)
    }

    before do
      allow(SlotAvailability).to receive(:new).and_return(slot_availability)
    end

    it 'returns 200 OK' do
      get :index, params
      expect(response).to have_http_status(:ok)
    end

    it 'lists available slots, as returned by SlotAvailability' do
      get :index, params
      expect(parsed_body).to include(
        'slots' => [
          '2016-02-15T13:30/14:30',
          '2016-02-22T13:30/14:30',
          '2016-02-29T13:30/14:30'
        ]
      )
    end
  end
end
