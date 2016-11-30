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
      before do
        create(:visit, created_at: 1.week.ago)
      end
      it { is_expected.to be_successful }
    end

    it_behaves_like 'disallows untrusted ips'
  end

  describe 'show' do
    let(:prison) { create :prison }
    subject { get :show, id: prison.id, locale: 'en' }
    it { is_expected.to be_successful }
  end

  describe 'confirmed_bookings' do
    let(:params) { { locale: 'en', format: 'csv' } }
    subject { get :confirmed_bookings, params }
    it { is_expected.to be_successful }
  end

  describe 'summary' do
    let(:prison) { create(:prison) }
    subject { get :summary, prison_id: prison.to_param, locale: 'en' }
    it { is_expected.to be_successful }
  end
end
