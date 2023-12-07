require 'rails_helper'

RSpec.describe MetricsController, type: :controller do
  describe 'index' do
    let(:range) { nil }
    let(:params) { { range:, locale: 'en' } }

    subject { get :index, params: }

    context 'with no range' do
      let(:range) { 'all_time' }

      it { is_expected.to be_successful }
    end

    context "with a range" do
      let(:range) { 'weekly' }

      before do
        create(:visit, created_at: 1.week.ago)
        create(:rejected_visit, created_at: 1.year.ago)
      end

      it { is_expected.to be_successful }
    end
  end

  describe 'summary' do
    let(:prison) { create(:prison) }

    subject { get :summary, params: { prison_id: prison.to_param, locale: 'en' } }

    it { is_expected.to be_successful }
  end
end
