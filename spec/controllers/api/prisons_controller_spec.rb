require 'rails_helper'

RSpec.describe Api::PrisonsController do
  let(:parsed_body) {
    JSON.parse(response.body)
  }

  let!(:prison) {
    create(
      :prison,
      id: 'e3148a7b-a667-449d-b11a-bc72835f5a26',
      name: 'Luna',
      postcode: 'XL1 1AA',
      translations: { 'xx' => { 'name' => 'Lüna' } }
    )
  }

  render_views

  describe 'index' do
    let(:params) { { format: :json } }

    it 'returns 200 OK' do
      get :index, params
      expect(response).to have_http_status(:ok)
    end

    it 'returns the id and name of each enabled prison' do
      get :index, params
      expect(parsed_body).to include(
        'prisons' => [include('id' => prison.id, 'name' => 'Luna')]
      )
    end

    it 'includes an API link for each prison' do
      get :index, params
      expect(parsed_body).to include(
        'prisons' => [
          include(
            '_links' => {
              'self' => {
                'href' => "http://test.host/api/prisons/#{prison.id}.json"
              }
            }
          )
        ]
      )
    end

    it 'localises prison details on Accept-Language header' do
      request.env['HTTP_ACCEPT_LANGUAGE'] = 'xx'
      get :index, params
      expect(parsed_body).to include(
        'prisons' => [include('name' => 'Lüna')]
      )
    end
  end

  describe 'show' do
    let(:params) { { id: prison.id, format: :json } }

    it 'returns 200 OK' do
      get :show, params
      expect(response).to have_http_status(:ok)
    end

    it 'returns prison details' do
      get :show, params
      expect(parsed_body).to include(
        'prison' => include(
          'id' => prison.id,
          'name' => 'Luna',
          'postcode' => 'XL1 1AA'
        )
      )
    end

    it 'localises prison details on Accept-Language header' do
      request.env['HTTP_ACCEPT_LANGUAGE'] = 'xx'
      get :show, params
      expect(parsed_body).to include(
        'prison' => include('name' => 'Lüna')
      )
    end
  end
end
