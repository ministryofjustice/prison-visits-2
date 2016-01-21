require 'rails_helper'

RSpec.describe ErrorsController do
  render_views

  %w[ 404 500 503 ].each do |status_code|
    it "renders #{status_code} page with the given status" do
      get :show, status_code: status_code
      expect(response.status).to eq(status_code.to_i)
    end
  end
end
