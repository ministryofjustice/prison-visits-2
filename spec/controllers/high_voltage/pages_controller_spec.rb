require 'rails_helper'

RSpec.describe HighVoltage::PagesController do
  render_views

  # Test that each static page is generated correctly
  Dir.glob(Rails.root.join('app', 'views', 'pages', '*.erb')).each do |file|
    page_name = file.split('/').last.split('.').first

    describe "when rendering #{page_name}" do
      before do
        get :show, id: page_name
      end

      it { should respond_with(:success) }
    end
  end
end
