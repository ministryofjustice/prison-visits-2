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

    before do
      stub_logged_in_user(
        user,
        active_session_estate,
        available_orgs: available_session_orgs)
    end

    context 'when the current estate is known' do
      let(:available_session_orgs) { [estate.sso_organisation_name] }
      let(:active_session_estate) { estate }

      it { is_expected.to eq(estate) }
    end

    context 'when the current estate is not known' do
      let(:available_session_orgs) { ['unknown'] }
      let(:active_session_estate) { estate }

      it { is_expected.to be_nil }
    end
  end

  describe '#available_estates' do
    subject('available_estates') { controller.available_estates }

    let!(:estate) { FactoryGirl.create(:estate) }
    let!(:other_estate) { FactoryGirl.create(:estate) }

    before do
      stub_logged_in_user(
        user,
        estate,
        available_orgs: available_session_orgs)
    end

    describe "when part of 'digital.noms.moj'" do
      let(:available_session_orgs) { ['digital.noms.moj'] }

      it { is_expected.to contain_exactly(estate, other_estate) }
    end

    describe 'when part of a some of the estates' do
      let(:available_session_orgs) { [estate.sso_organisation_name] }

      it { is_expected.to eq([estate]) }
    end
  end
end
