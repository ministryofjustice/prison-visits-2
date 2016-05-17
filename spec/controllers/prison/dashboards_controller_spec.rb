require 'rails_helper'
require_relative '../untrusted_examples'

RSpec.describe Prison::DashboardsController, type: :controller do
  subject { get :index, locale: 'en' }

  it_behaves_like 'disallows untrusted ips'

  context '#index' do
    subject { get :index, locale: 'en' }

    it { is_expected.to be_successful }
  end

  context '#show' do
    let(:estate) { FactoryGirl.create(:estate) }
    subject { get :show, estate_id: estate.finder_slug, locale: 'en' }

    it { is_expected.to be_successful }
  end
end
