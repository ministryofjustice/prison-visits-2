require 'rails_helper'

RSpec.describe Api::RootController do
  let(:parsed_body) {
    JSON.parse(response.body)
  }

  render_views

  describe 'index' do
    it 'returns 200 OK' do
      get :index, format: :json
      expect(response).to have_http_status(:ok)
    end

    it 'returns a link to the prisons endpoint' do
      get :index, format: :json
      expect(parsed_body).to include(
        '_links' => {
          'prisons' => {
            'href' => 'http://test.host/api/prisons'
          }
        }
      )
    end

    it 'returns an error if the format is not json' do
      get :index, format: :xml
      expect(response.status).to eq(406)
      expect(parsed_body).to eq("message" => "Only JSON supported")
    end
  end
end
