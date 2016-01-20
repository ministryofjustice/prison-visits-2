require 'rails_helper'

RSpec.describe ErrorsController do
  render_views

  %w[ 404 500 503 ].each do |status_code|
    describe "when rendering #{status_code} page" do
      before do
        get :show, status_code: status_code
      end

      specify { expect(response.status).to eq(status_code.to_i) }
    end
  end
end
