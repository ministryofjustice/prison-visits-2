require 'rails_helper'
require_relative 'untrusted_examples'

RSpec.describe MetricsController, type: :controller do
  describe 'index' do
    let(:range) { nil }
    let(:params) { { range: nil, locale: 'en' } }

    subject { get :index, params }

    context 'with no range' do
      let(:range) { nil }
      it { is_expected.to be_successful }
    end

    context "with a range" do
      let(:range) { 'weekly' }
      it { is_expected.to be_successful }
    end

    it_behaves_like 'disallows untrusted ips'
  end
end
