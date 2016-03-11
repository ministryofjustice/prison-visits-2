require 'rails_helper'
require_relative 'untrusted_examples'

RSpec.describe MetricsController, type: :controller do
  describe 'index' do
    let(:params) { { locale: 'en' } }

    subject { get :index, params }

    it { is_expected.to be_successful }

    it_behaves_like 'disallows untrusted ips'
  end
end

