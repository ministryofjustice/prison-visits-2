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
        # mailers: {
        #   description: "Email queue", ok: true,
        #   oldest: nil, count: 0
        # },
        # zendesk: {
        #   description: "Zendesk queue", ok: true,
        #   oldest: nil, count: 0
        # },
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
        # 'mailers' => {
        #   'description' => "Email queue",
        #   'ok' => true,
        #   'oldest' => nil,
        #   'count' => 0
        # },
        # 'zendesk' => {
        #   'description' => "Zendesk queue",
        #   'ok' => true,
        #   'oldest' => nil,
        #   'count' => 0
        # },
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

  # context 'when there are no queue items' do
  #   before do
  #     get :index
  #   end

  #   it 'reports empty queue statuses' do
  #     expect(parsed_body).to include(
  #       'mailers' => include('oldest' => nil, 'count' => 0)
  #       # 'zendesk' => include('oldest' => nil, 'count' => 0)
  #     )
  #   end
  # end

  # context 'when there are queue items' do
  #   let(:mq_created_at) { Time.at(1_440_685_647).utc }
  #   # let(:zq_created_at) { Time.at(1_440_685_724).utc }

  #   before do
  #     allow(healthcheck).to receive(:checks).and_return(
  #       database: {
  #         description: "Postgres database", ok: true
  #       },
  #       mailers: {
  #         description: "Email queue", ok: true,
  #         oldest: mq_created_at, count: 1
  #       },
  #       # zendesk: {
  #       #   description: "Zendesk queue", ok: true,
  #       #   oldest: zq_created_at, count: 2
  #       # },
  #       ok: true
  #     )
  #     get :index
  #   end

  #   it 'reports timestamps in RFC 3339 format' do
  #     expect(parsed_body).to include(
  #       'mailers' => include('oldest' => '2015-08-27T14:27:27.000Z')
  #       # 'zendesk' => include('oldest' => '2015-08-27T14:28:44.000Z')
  #     )
  #   end
  # end
end
