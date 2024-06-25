require 'rails_helper'

RSpec.describe InfoController, type: :controller do
  let(:parsed_body) {
    JSON.parse(response.body)
  }

  subject(:index_request) { get :index }

  context 'when everything is OK' do
    before do
      ENV['GIT_BRANCH'] = 'GIT_BRANCH'
      ENV['BUILD_NUMBER'] = 'BUILD_NUMBER'
      ENV['PRODUCT_ID'] = 'PRODUCT_ID'
    end

    it { is_expected.to be_successful }

    it 'returns the healthcheck data as JSON' do
      index_request

      expect(parsed_body).to eq(
        'build' => { "artifact" => "prison-visits-public",
                     "name" => "prison-visits-public",
                     "version" => "BUILD_NUMBER" }, "git" => { "branch" => "GIT_BRANCH" },
        "productId" => "PRODUCT_ID"
      )
    end
  end
end
