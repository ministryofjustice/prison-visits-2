require 'rails_helper'

RSpec.describe HighVoltage::PagesController do
  render_views

  %w[ cookies terms_and_conditions unsubscribe ].each do |page_name|
    describe "when rendering #{page_name}" do
      before do
        get :show, id: page_name
      end

      specify { expect(response.status).to eq(200) }
    end
  end
end
