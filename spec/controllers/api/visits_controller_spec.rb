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

  around do |example|
    travel_to Time.zone.local(2016, 2, 3, 14, 0) do
      example.run
    end
  end

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

    it 'fails if a (top-level) parameter is missing' do
      params.delete(:contact_email_address)
      post :create, params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_body['message']).
        to eq('Missing parameter: contact_email_address')
    end

    it 'fails if the prisoner is invalid' do
      params[:prisoner][:first_name] = nil
      post :create, params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_body['message']).
        to eq('Invalid parameter: prisoner (First name is required)')
    end

    it 'fails if the visitors are invalid' do
      params[:visitors][0][:first_name] = nil
      post :create, params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_body['message']).
        to eq('Invalid parameter: visitors ()')
    end

    it 'fails if slot_options is not an array' do
      params[:slot_options] = 'string'
      post :create, params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_body['message']).
        to eq('Invalid parameter: slot_options must contain >= slot')
    end

    it 'fails if slot_options does not contain at least 1 slot' do
      params[:slot_options] = 'string'
      post :create, params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_body['message']).
        to eq('Invalid parameter: slot_options must contain >= slot')
    end

    it 'returns an error if the slot does not exist' do
      params[:slot_options] = ['2016-02-15T04:00/04:30']
      post :create, params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_body['message']).
        to eq('Invalid parameter: slot_options (Option 0 is not included in the list)')
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

    it 'fails if the visit does not exist' do
      params[:id] = '123'
      get :show, params
      expect(response).to have_http_status(:not_found)
      expect(parsed_body['message']).to eq('Not found')
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

    it 'fails if the visit does not exist' do
      params[:id] = '123'
      delete :destroy, params
      expect(response).to have_http_status(:not_found)
      expect(parsed_body['message']).to eq('Not found')
    end
  end
end
