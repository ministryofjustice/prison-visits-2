require 'rails_helper'

RSpec.describe Prison::DashboardsController, type: :controller do
  let(:estate) { FactoryBot.create(:estate) }
  let(:user) { FactoryBot.create(:user) }

  subject { get :inbox, params: { estate_id: estate.finder_slug } }

  describe '#inbox' do
    let(:prison) { FactoryBot.create(:prison, estate: estate) }

    subject { get :inbox, params: { estate_id: estate.finder_slug } }

    context "when logged in" do
      before do
        login_user(user, current_estates: [estate])
      end

      it { is_expected.to be_successful }
    end

    context "when logged out" do
      it { is_expected.not_to be_successful }
    end
  end

  describe '#processed' do
    let(:prison) { FactoryBot.create(:prison, estate: estate) }

    subject { get :processed, params: { estate_id: estate.finder_slug } }

    context "when logged out" do
      it { is_expected.not_to be_successful }
    end

    context "when logged in" do
      before do
        login_user(user, current_estates: [estate])
      end

      it { is_expected.to be_successful }

      context 'when there are more processed visits than the default' do
        before do
          stub_const("#{described_class}::NUMBER_VISITS", 2)
          FactoryBot.create(:booked_visit, prison: prison)
          FactoryBot.create(:booked_visit, prison: prison)
        end

        it 'sets up the view to render only one visit' do
          subject
          expect(assigns[:processed_visits].size).to eq(1)
          expect(assigns[:all_visits_shown]).to eq(false)
        end
      end
    end
  end

  describe '#search' do
    let(:prison) { FactoryBot.create(:prison, estate: estate) }

    subject { get :search, params: { estate_id: estate.finder_slug } }

    context "when logged in" do
      before do
        login_user(user, current_estates: [estate])
      end

      it { is_expected.to be_successful }

      context 'when filtering requested visits by prisoner number' do
        subject do
          get :search, params: {
            estate_id: estate.finder_slug,
            prisoner_number: visit.prisoner_number
          }
        end

        let!(:visit) { FactoryBot.create(:visit, prison: prison) }

        it 'returns the requested visit for that prisoner' do
          subject
          expect(assigns[:requested_visits].size).to eq(1)
        end
      end

      context 'when filtering processed visits by prisoner number' do
        subject do
          get :search, params: {
            estate_id: estate.finder_slug,
            prisoner_number: visit.prisoner_number
          }
        end

        let!(:visit) { FactoryBot.create(:booked_visit, prison: prison) }

        it 'returns the processed visit for that prisoner' do
          subject
          expect(assigns[:processed_visits].size).to eq(1)
        end
      end
    end
  end
end
