require 'rails_helper'
require_relative 'untrusted_examples'

RSpec.describe StaffInfoController, type: :controller do
  describe '#show' do
    subject { get :show }

    it { expect(response.status).to eq(200) }
    it { is_expected.to render_template(:show) }
    it_behaves_like 'disallows untrusted ips'
  end
end
