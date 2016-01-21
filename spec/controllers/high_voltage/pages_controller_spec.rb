require 'rails_helper'

RSpec.describe HighVoltage::PagesController do
  render_views

  %w[ cookies terms_and_conditions unsubscribe ].each do |page_name|
    it "renders #{page_name} successfully" do
      get :show, id: page_name
      expect(response).to have_http_status(:ok)
    end
  end
end
