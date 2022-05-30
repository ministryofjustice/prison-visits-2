require 'rails_helper'

RSpec.describe DownloadsController, type: :controller  do
  describe '#index' do
    subject { get :index }

    it { expect(response.status).to eq(200) }
    it { is_expected.to render_template(:index) }
  end
end
