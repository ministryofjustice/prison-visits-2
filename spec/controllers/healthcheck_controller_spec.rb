require 'rails_helper'

RSpec.describe HealthcheckController, type: :controller do
  let(:parsed_body) {
    JSON.parse(response.body)
  }

  let(:healthcheck) {
    double(
      Healthcheck,
      ok?: true,
      checks: {
        database: {
          description: "Postgres database", ok: true
        },
        ok: true
      }
    )
  }

  before do
    allow(Healthcheck).to receive(:new).and_return(healthcheck)
  end

  context 'when everything is OK' do
    before do
      get :index
    end

    it 'returns an HTTP Success status' do
      expect(response).to be_successful
    end

    it 'returns the healthcheck data as JSON' do
      expect(parsed_body).to eq(
        'database' => {
          'description' => "Postgres database",
          'ok' => true
        },
        'ok' => true
      )
    end
  end

  context 'when the healthcheck is not OK' do
    before do
      allow(healthcheck).to receive(:ok?).and_return(false)
      get :index
    end

    it 'returns an HTTP Bad Gateway status' do
      expect(response).to have_http_status(:service_unavailable)
    end
  end
end
