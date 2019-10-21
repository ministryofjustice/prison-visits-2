require 'rails_helper'

RSpec.describe StaffInfoController, type: :controller do
  describe '#show' do
    before do
      login_user(create(:user), current_estates: [create(:estate)])
    end

    subject { get :show }

    it { expect(response.status).to eq(200) }
    it { is_expected.to render_template(:show) }

    it_behaves_like 'disallows untrusted ips'
  end
end
