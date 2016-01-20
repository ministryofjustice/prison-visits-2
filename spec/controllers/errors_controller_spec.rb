require 'rails_helper'

RSpec.describe ErrorsController do
  render_views

  # Test that each static page is generated correctly
  Dir.glob(Rails.root.join('app', 'views', 'errors', '*.erb')).each do |file|
    status_code = file.split('/').last.split('.').first

    describe "when rendering #{status_code} page" do
      before do
        get :show, status_code: status_code
      end

      specify { expect(response.status).to eq(status_code.to_i) }
    end
  end
end
