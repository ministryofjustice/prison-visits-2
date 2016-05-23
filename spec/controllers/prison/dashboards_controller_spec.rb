require 'rails_helper'
require_relative '../untrusted_examples'

RSpec.describe Prison::DashboardsController, type: :controller do
  subject { get :index }

  it_behaves_like 'disallows untrusted ips'

  context '#index' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  context '#show' do
    let(:estate) { FactoryGirl.create(:estate) }
    subject { get :show, estate_id: estate.finder_slug }

    it { is_expected.to be_successful }
  end

  context '#processed' do
    let(:estate) { FactoryGirl.create(:estate) }
    let(:prison) { FactoryGirl.create(:prison, estate: estate) }
    subject { get :processed, estate_id: estate.finder_slug }

    it { is_expected.to be_successful }

    context 'filtering by prisoner number' do
      subject do
        get :processed,
          estate_id: estate.finder_slug,
          prisoner_number: visit.prisoner_number
      end

      let!(:visit) { FactoryGirl.create(:booked_visit, prison: prison) }

      it 'returns the visit for that prisoner' do
        subject
        expect(assigns[:processed_visits].size).to eq(1)
      end
    end

    context 'when there are more processed visits than the default' do
      before do
        stub_const("#{described_class}::NUMBER_VISITS", 2)
        FactoryGirl.create(:booked_visit, prison: prison)
        FactoryGirl.create(:booked_visit, prison: prison)
      end

      it 'sets up the view to render only one visit' do
        subject
        expect(assigns[:processed_visits].size).to eq(1)
        expect(assigns[:all_visits_shown]).to eq(false)
      end
    end
  end
end
