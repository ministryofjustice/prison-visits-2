require 'rails_helper'
require_relative '../untrusted_examples'

RSpec.describe Prison::DashboardsController, type: :controller do
  let(:estate) { FactoryGirl.create(:estate) }
  let(:user) { FactoryGirl.create(:user) }
  subject { get :unprocessed, estate_id: estate.finder_slug }

  it_behaves_like 'disallows untrusted ips'

  describe '#unprocessed' do
    let(:estate) { FactoryGirl.create(:estate) }
    subject { get :unprocessed, estate_id: estate.finder_slug }

    context "when logged in" do
      before do
        sign_in user
      end

      it { is_expected.to be_successful }
    end

    context "when logged out" do
      it { is_expected.to_not be_successful }
    end
  end

  describe '#processed' do
    let(:estate) { FactoryGirl.create(:estate) }
    let(:prison) { FactoryGirl.create(:prison, estate: estate) }
    subject { get :processed, estate_id: estate.finder_slug }

    context "when logged out" do
      it { is_expected.to_not be_successful }
    end

    context "when logged in" do
      before do
        sign_in user
      end

      it { is_expected.to be_successful }

      context 'filtering by prisoner number' do
        subject do
          get :processed,
            estate_id: estate.finder_slug,
            prisoner_number: visit.prisoner_number
        end

        let!(:visit) { FactoryGirl.create(:booked_visit, prison: prison) }

        it 'returns the visit for that prisoner' do
          subject
          expect(assigns[:processed_visits].size).to eq(1)
        end
      end

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

  context '#print_visits' do
    let(:estate) { FactoryGirl.create(:estate) }
    let(:prison) { FactoryGirl.create(:prison, estate: estate) }
    let(:slot_granted1) { '2016-01-01T09:00/10:00' }
    let(:slot_granted2) { '2016-01-01T12:00/14:00' }

    subject { get :print_visits, estate_id: estate.finder_slug, visit_date: visit_date }

    context "when logged out" do
      let(:visit_date) { nil }

      it { is_expected.to_not be_successful }
    end

    context "when logged in" do
      before do
        sign_in user
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
        let(:visit_date) { nil }

        it 'assigns an empty hash' do
          subject
          expect(assigns[:data]).to eq({})
        end
      end

      describe 'date supplied' do
        let(:visit_date) { '2016-01-01' }

        it 'assigns visits with a slot granted on the date' do
          subject

          expect(assigns[:data][visit1.slot_granted].size).to eq(1)
          expect(assigns[:data][visit2.slot_granted].size).to eq(1)
        end
      end
    end
  end
end
