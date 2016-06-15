require 'rails_helper'
require_relative '../untrusted_examples'

RSpec.describe Prison::VisitsController, type: :controller do
  let(:visit) { FactoryGirl.create(:visit) }

  describe '#process_visit' do
    subject do
      get :process_visit, id: visit.id, locale: 'en'
    end

    context 'when is processable' do
      context 'when is part of the dashboard trial' do
        before do
          allow(Rails.configuration).
            to receive(:dashboard_trial).
            and_return([visit.prison.estate.name])
        end

        context 'and there is no logged in user' do
          it { is_expected.to_not be_successful }
        end

        context 'and there is a logged in user' do
          let(:user) { FactoryGirl.create(:user, estate: visit.prison.estate) }

          before do
            sign_in user
          end

          it { is_expected.to render_template('process_visit') }
        end
      end

      context "when it isn't part of the dashboard trial" do
        it { is_expected.to render_template('process_visit') }
      end
    end

    context 'when is unprocessble' do
      let!(:visit) { FactoryGirl.create(:booked_visit) }
      it { is_expected.to redirect_to(prison_deprecated_visit_path(visit)) }
    end
  end

  describe '#update' do
    subject do
      put :update,
        id: visit.id,
        booking_response: booking_response,
        locale: 'en'
    end

    let(:booking_response) { { selection: 'slot_0' } }

    it_behaves_like 'disallows untrusted ips'

    context 'when invalid' do
      it { is_expected.to render_template('process_visit') }
    end

    context 'when valid' do
      let(:booking_response) { { selection: 'slot_0', reference_no: 'none' } }

      it { is_expected.to redirect_to(prison_deprecated_visit_path(visit)) }
    end
  end

  describe '#show' do
    subject { get :show, id: visit.id }
    let(:user) { FactoryGirl.create(:user, estate: visit.prison.estate) }

    it_behaves_like 'disallows untrusted ips'

    context "when logged in" do
      before do
        sign_in user
      end

      it { is_expected.to render_template('show') }
      it { is_expected.to be_successful }
    end

    context "when logged out" do
      it { is_expected.to_not be_successful }
    end
  end

  describe '#cancel' do
    let(:visit) { FactoryGirl.create(:booked_visit) }
    let(:mailing) { double(Mail::Message, deliver_later: nil) }

    subject do
      delete :cancel,
        id: visit.id,
        cancellation_reason: 'slot_unavailable',
        locale: 'en'
    end

    it 'cancels the visit' do
      expect { subject }.
        to change { visit.reload.processing_state }.to('cancelled')
    end

    it_behaves_like 'disallows untrusted ips'

    context 'when there is a user logged in' do
      let(:user) { FactoryGirl.create(:user, estate: visit.prison.estate) }

      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      it { is_expected.to redirect_to(prison_visit_show_path(visit)) }
    end

    context "when there isn't a user logged in" do
      it { is_expected.to redirect_to(prison_deprecated_visit_path(visit)) }
    end

    context 'when the visit is already cancelled' do
      let(:visit) { FactoryGirl.create(:cancelled_visit) }

      it { is_expected.to redirect_to(prison_deprecated_visit_path(visit)) }
    end
  end
end
