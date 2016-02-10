require 'rails_helper'

RSpec.describe Api::SlotsController do
  let(:parsed_body) {
    JSON.parse(response.body)
  }

  let!(:prison) {
    create(
      :prison,
      slot_details: { 'recurring' => { 'mon' => ['1330-1430'] } }
    )
  }

  around do |example|
    travel_to Time.zone.local(2016, 2, 3, 14, 0) do
      example.run
    end
  end

  render_views

  describe 'index' do
    let(:params) {
      {
        format: :json,
        prison_id: prison.id,
        prisoner_no: 'a1234bc',
        first_name: 'Winston',
        last_name: 'Smith',
        date_of_birth: '1950-01-01'
      }
    }

    it 'returns 200 OK' do
      get :index, params
      expect(response).to have_http_status(:ok)
    end

    it 'lists available slots' do
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
