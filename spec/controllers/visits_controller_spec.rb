require 'rails_helper'

RSpec.describe VisitsController, type: :controller do
  describe 'show' do
    let(:visit) { create(:visit) }

    it 'assigns the visit to @visit' do
      get :show, id: visit.id
      expect(assigns(:visit)).to eq(visit)
    end
  end
end
