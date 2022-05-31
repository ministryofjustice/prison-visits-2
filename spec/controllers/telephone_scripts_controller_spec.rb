require 'rails_helper'

RSpec.describe TelephoneScriptsController, type: :controller  do
  describe '#index' do
    subject { get :show }

    it { expect(response.status).to eq(200) }
    it { is_expected.to render_template(:show) }
  end
end
