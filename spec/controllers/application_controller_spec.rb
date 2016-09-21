require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }

  controller do
    def index
      head :ok
    end
  end

  describe '#set_locale' do
    context 'with an invalid locale' do
      it 'defaults to en' do
        expect {
          get :index, locale: 'ent'
        }.to_not raise_error
      end
    end
  end

  describe '#current_estate' do
    subject(:current_estate) { controller.current_estate }

    let(:estate) { FactoryGirl.create(:estate) }
    let(:estate2) { FactoryGirl.create(:estate) }

    before do
      login_user(user, estate, available_estates: [estate])
    end

    it 'returns the current_estate if set' do
      login_user(user, estate)
      expect(current_estate).to eq(estate)
    end

    it 'verifies that the current estate is available to the user, returning the default estate if not' do
      login_user(user, estate2, available_estates: [estate])
      expect(current_estate).to eq(estate)
    end

    it 'returns the default estate if a current_estate is not set' do
      login_user(user, estate)
      controller.session.delete(:current_estate)
      expect(current_estate).to eq(estate)
    end

    it 'returns the default estate if the current_estate does not exist' do
      login_user(user, estate)
      controller.session[:current_estate] = 'missing_id'
      expect(current_estate).to eq(estate)
    end
  end
end
