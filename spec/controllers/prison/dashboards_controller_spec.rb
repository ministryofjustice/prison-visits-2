require 'rails_helper'
require_relative '../untrusted_examples'

RSpec.describe Prison::DashboardsController, type: :controller do
  let(:estate) { FactoryGirl.create(:estate) }
  let(:user) { FactoryGirl.create(:user) }
  subject { get :inbox, estate_id: estate.finder_slug }

  it_behaves_like 'disallows untrusted ips'

  describe '#inbox' do
    let(:prison) { FactoryGirl.create(:prison, estate: estate) }
    subject { get :inbox, estate_id: estate.finder_slug }

    context "when logged in" do
      before do
        stub_logged_in_user(user, estate)
      end

      it { is_expected.to be_successful }
    end

    context "when logged out" do
      it { is_expected.to_not be_successful }
    end
  end

  describe '#processed' do
    let(:prison) { FactoryGirl.create(:prison, estate: estate) }
    subject { get :processed, estate_id: estate.finder_slug }

    context "when logged out" do
      it { is_expected.to_not be_successful }
    end

    context "when logged in" do
      before do
        stub_logged_in_user(user, estate)
      end

      it { is_expected.to be_successful }

      context 'when there are more processed visits than the default' do
        before do
          stub_const("#{described_class}::NUMBER_VISITS", 2)
          FactoryGirl.create(:booked_visit, prison: prison)
          FactoryGirl.create(:booked_visit, prison: prison)
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
    let(:prison) { FactoryGirl.create(:prison, estate: estate) }
    subject { get :search, estate_id: estate.finder_slug }

    context "when logged in" do
      before do
        stub_logged_in_user(user, estate)
      end

      it { is_expected.to be_successful }

      context 'filtering requested visits by prisoner number' do
        subject do
          get :search,
            estate_id: estate.finder_slug,
            prisoner_number: visit.prisoner_number
        end

        let!(:visit) { FactoryGirl.create(:visit, prison: prison) }

        it 'returns the requested visit for that prisoner' do
          subject
          expect(assigns[:requested_visits].size).to eq(1)
        end
      end

      context 'filtering processed visits by prisoner number' do
        subject { get :processed, estate_id: estate.finder_slug }
        subject do
          get :search,
            estate_id: estate.finder_slug,
            prisoner_number: visit.prisoner_number
        end

        let!(:visit) { FactoryGirl.create(:booked_visit, prison: prison) }

        it 'returns the processed visit for that prisoner' do
          subject
          expect(assigns[:processed_visits].size).to eq(1)
        end
      end
    end
  end

  context '#print_visits' do
    let(:prison) { FactoryGirl.create(:prison, estate: estate) }
    let(:slot_granted1) { '2016-01-01T09:00/10:00' }
    let(:slot_granted2) { '2016-01-01T12:00/14:00' }

    subject do
      get :print_visits, estate_id: estate.finder_slug, visit_date: visit_date
    end

    context "when logged out" do
      let(:visit_date) { nil }

      it { is_expected.to_not be_successful }
    end

    context "when logged in" do
      before do
        stub_logged_in_user(user, estate)
      end

      let!(:visit1) do
        FactoryGirl.create(:booked_visit,
          prison: prison,
          slot_granted: slot_granted1)
      end

      let!(:visit2) do
        FactoryGirl.create(:booked_visit,
          prison: prison,
          slot_granted: slot_granted2)
      end

      describe 'no date supplied' do
        let(:visit_date) { '' }

        it 'assigns an empty hash' do
          subject
          expect(assigns[:data]).to eq({})
        end
      end

      describe 'with an invalid date' do
        let(:visit_date) { '2010913' }

        it { expect { subject }.to_not raise_error }
      end

      describe 'date supplied' do
        let(:visit_date) { '2016-01-01' }

        it 'assigns visits with a slot granted on the date' do
          subject

          expect(assigns[:data]['booked'][visit1.slot_granted].size).to eq(1)
          expect(assigns[:data]['booked'][visit2.slot_granted].size).to eq(1)
        end

        context 'as a csv' do
          subject do
            get :print_visits,
              estate_id: estate.finder_slug,
              visit_date: visit_date,
              format: :csv
          end

          it { is_expected.to be_successful }
        end
      end
    end
  end

  context '#switch_estate' do
    let(:other_estate) { FactoryGirl.create(:estate) }
    subject do
      post :switch_estate, sso_org: other_estate.sso_organisation_name
    end

    context "when logged out" do
      let(:visit_date) { nil }

      it { is_expected.to_not be_successful }
    end

    context "when logged in" do
      before do
        stub_logged_in_user(
          user,
          estate,
          available_estates: [estate, other_estate])

        request.env['HTTP_REFERER'] = '/previous/path'
      end

      it 'updates the session current estate' do
        subject
        expect(controller.current_estate).to eq(other_estate)
      end

      it { is_expected.to redirect_to('/previous/path') }
    end
  end
end
