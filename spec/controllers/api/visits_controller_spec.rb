require 'rails_helper'

RSpec.describe Api::VisitsController do
  render_views

  let(:visit) { create(:visit) }
  let(:prison) {
    create(
      :prison,
      slot_details: { 'recurring' => { 'mon' => ['1330-1430'] } }
    )
  }

  let(:parsed_body) {
    JSON.parse(response.body)
  }

  describe 'create' do
    let(:params) {
      {
        format: :json,
        prison_id: prison.id,
        prisoner: {
          first_name: 'Joe',
          last_name: 'Bloggs',
          date_of_birth: '1980-01-01',
          number: 'A1234BC'
        },
        visitors: [
          {
            first_name: 'Joe',
            last_name: 'Bloggs',
            date_of_birth: '1980-01-01'
          }
        ],
        slot_options: [
          '2016-02-15T13:30/14:30'
        ],
        contact_email_address: 'foo@example.com',
        contact_phone_no: '1234567890',
        locale: 'en'
      }
    }

    it 'creates a new visit booking request' do
      post :create, params
      expect(response).to have_http_status(:ok)
      expect(parsed_body['visit']).to have_key('id')
      expect(parsed_body['visit']['processing_state']).to eq('requested')
    end
  end

  describe 'show' do
    let(:params) {
      {
        format: :json,
        id: visit.id
      }
    }

    it 'returns visit status' do
      get :show, params
      expect(response).to have_http_status(:ok)
      expect(parsed_body['visit']['processing_state']).to eq('requested')
    end
  end

  describe 'destroy' do
    let(:params) {
      {
        format: :json,
        id: visit.id
      }
    }

    let(:mailing) {
      double(Mail::Message, deliver_later: nil)
    }

    it 'cancels a visit request' do
      delete :destroy, params
      expect(response).to have_http_status(:ok)
      expect(parsed_body['visit']['processing_state']).to eq('withdrawn')
    end

    it 'triggers a cancellation email to staff' do
      expect(PrisonMailer).to receive(:withdrawn).once.and_return(mailing)
      delete :destroy, params
    end
  end
end
