require 'rails_helper'
require_relative 'untrusted_examples'

RSpec.describe MetricsController, type: :controller do
  describe 'index' do
    let(:range) { nil }
    let(:params) { { range: range, locale: 'en' } }

    subject { get :index, params }

    context 'with no range' do
      let(:range) { 'all_time' }
      it { is_expected.to be_successful }
    end

    context "with a range" do
      let(:range) { 'weekly' }
      before { FactoryGirl.create(:visit, created_at: 1.week.ago) }
      it { is_expected.to be_successful }
    end

    it_behaves_like 'disallows untrusted ips'
  end
end
