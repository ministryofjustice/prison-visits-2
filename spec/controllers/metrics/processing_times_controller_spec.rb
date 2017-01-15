require "rails_helper"

RSpec.describe Metrics::ProcessingTimesController do
  let!(:prisons) { create_list :prison, 2 }
  render_views

  describe 'index' do
    before do
      get :index, locale: 'en'
    end

    it { expect(response).to be_success }

    it 'renders the graph containers' do
      expect(response.body).to have_css('.js-Metrics')
      expect(response.body).to have_css('.js-VisitsCounts')
      expect(response.body).to have_css('.js-TimelyVisitsCount')
      expect(response.body).to have_css('.js-RejectionPercentages')
    end
  end

  describe 'show' do
    before do
      get :show, locale: 'en', id: prisons.first.id
    end

    it { expect(response).to be_success }

    it 'renders the graph containers' do
      expect(response.body).to have_css('.js-Metrics')
      expect(response.body).to have_css('.js-VisitsCounts')
      expect(response.body).to have_css('.js-TimelyVisitsCount')
      expect(response.body).to have_css('.js-RejectionPercentages')
    end

  end
end
