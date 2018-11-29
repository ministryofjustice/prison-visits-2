require 'rails_helper'

RSpec.describe Prison::PrintVisitsController do
  let(:estate) { create(:estate) }
  let(:user)   { create(:user) }
  let(:prison) { create(:prison, estate: estate) }

  subject { response }

  describe '#new' do
    context "when logged out" do
      before do
        get :new, params: { estate_id: estate.finder_slug }
      end

      it { is_expected.to redirect_to("/auth/mojsso") }
    end

    context "when logged in" do
      before do
        login_user(user, current_estates: [estate])
        get :new, params: { estate_id: estate.finder_slug }
      end

      it { is_expected.to be_successful }
    end
  end

  describe '#show' do
    let(:slot_granted1) { '2017-12-23T09:00/10:00' }
    let(:slot_granted2) { '2017-12-23T12:00/14:00' }

    context "when logged out" do
      let(:visit_date) { nil }

      before do
        get :show, params: { visit_date: { "day" => "23", "month" => "12", "year" => "2017" } }
      end

      it { is_expected.to redirect_to("/auth/mojsso") }
    end

    context "when logged in" do
      before do
        login_user(user, current_estates: [estate])
      end

      let!(:visit1) do
        create(:booked_visit,
          prison: prison,
          slot_granted: slot_granted1)
      end

      let!(:visit2) do
        create(:booked_visit,
          prison: prison,
          slot_granted: slot_granted2)
      end

      describe 'with an invalid date' do
        context 'with an empty visit date param' do
          let(:visit_date) { {} }

          it 'raises an error' do
            expect {
              get :show, params: { print_visits: { visit_date: visit_date } }
            }.to raise_error ActionController::ParameterMissing
          end
        end

        context 'with non-parsable date' do
          let(:visit_date) { { "day" => "43", "month" => "12", "year" => "2017" } }

          it 'does not raises an error'  do
            expect {
              get :show, params: { print_visits: { visit_date: visit_date } }
            }.not_to raise_error
          end
        end
      end

      describe 'date supplied' do
        let(:visit_date) { { "day" => "23", "month" => "12", "year" => "2017" } }
        let(:format)     { :html }

        before do
          get :show, params: { print_visits: { visit_date: visit_date }, format: format }
        end

        context 'with an empty date' do
          let(:visit_date) { { "day" => "", "month" => "", "year" => "" } }

          it 'assigns an empty search result' do
            expect(assigns[:data]).to eq({})
          end
        end

        context 'with a valid' do
          let(:visit_date) { { "day" => "23", "month" => "12", "year" => "2017" } }

          it 'assigns visits with a slot granted on the date' do
            prison_name = visit1.prison_name
            expect(assigns[:data][prison_name]['booked'][visit1.slot_granted].size).to eq(1)
            expect(assigns[:data][prison_name]['booked'][visit2.slot_granted].size).to eq(1)
          end

          context 'when as a csv' do
            let(:format) { :csv }

            it { is_expected.to be_successful }
          end
        end
      end
    end
  end
end
