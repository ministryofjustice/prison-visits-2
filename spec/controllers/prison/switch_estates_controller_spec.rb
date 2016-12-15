require 'rails_helper'

RSpec.describe Prison::SwitchEstatesController, type: :controller do
  context '#create' do
    let(:user) { FactoryGirl.create(:user) }
    let(:estate) { FactoryGirl.create(:estate) }
    let(:estate2)      { create(:estate) }
    let(:other_estate) { estate2 }
    let(:estates_id) { [other_estate.id] }
    subject do
      post :create, estates_id: estates_id
    end

    context "when logged out" do
      it { is_expected.to_not be_successful }
    end

    context "when logged in" do
      before do
        login_user(user, current_estates: [estate], available_estates: [estate, estate2])
        request.env['HTTP_REFERER'] = '/previous/path'
      end

      it 'updates the session current estate' do
        subject
        expect(controller.current_estates).to eq([other_estate])
      end

      it { is_expected.to redirect_to('/previous/path') }

      context 'when switching to an inaccessible estate' do
        let(:other_estate) { create(:estate) }

        it 'does not updated the current estate' do
          subject
          expect(controller.current_estates).to eq([estate])
        end
      end

      context "with an empty selection" do
        let(:estates_id) { [] }

        it 'does not update the current selection' do
          expect { subject }.to_not change { controller.current_estates }
        end
      end
    end
  end
end
