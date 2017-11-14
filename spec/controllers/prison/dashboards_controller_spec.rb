require 'rails_helper'
require_relative '../untrusted_examples'

RSpec.describe Prison::DashboardsController, type: :controller do
  let(:estate) { FactoryBot.create(:estate) }
  let(:user) { FactoryBot.create(:user) }

  subject { get :inbox, params: { estate_id: estate.finder_slug } }

  it_behaves_like 'disallows untrusted ips'

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

  context 'with #print_visits' do
    let(:prison) { FactoryBot.create(:prison, estate: estate) }
    let(:slot_granted1) { '2016-01-01T09:00/10:00' }
    let(:slot_granted2) { '2016-01-01T12:00/14:00' }

    subject do
      get :print_visits, params: { estate_id: estate.finder_slug, visit_date: visit_date }
    end

    context "when logged out" do
      let(:visit_date) { nil }

      it { is_expected.not_to be_successful }
    end

    context "when logged in" do
      before do
        login_user(user, current_estates: [estate])
      end

      let!(:visit1) do
        FactoryBot.create(:booked_visit,
          prison: prison,
          slot_granted: slot_granted1)
      end

      let!(:visit2) do
        FactoryBot.create(:booked_visit,
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

        it { expect { subject }.not_to raise_error }
      end

      describe 'date supplied' do
        let(:visit_date) { '2016-01-01' }

        it 'assigns visits with a slot granted on the date' do
          subject

          prison_name = visit1.prison_name
          expect(assigns[:data][prison_name]['booked'][visit1.slot_granted].size).to eq(1)
          expect(assigns[:data][prison_name]['booked'][visit2.slot_granted].size).to eq(1)
        end

        context 'when as a csv' do
          subject do
            get :print_visits, params: {
              estate_id: estate.finder_slug,
              visit_date: visit_date,
              format: :csv
            }
          end

          it { is_expected.to be_successful }
        end
      end
    end
  end
end
