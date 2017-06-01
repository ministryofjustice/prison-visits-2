require 'rails_helper'
require_relative '../untrusted_examples'

RSpec.describe Prison::VisitsController, type: :controller do
  let(:visit) { FactoryGirl.create(:visit) }
  let(:estate) { visit.prison.estate }

  describe '#process_visit' do
    subject do
      get :process_visit, id: visit.id, locale: 'en'
    end

    context 'when is processable' do
      context 'and there is no logged in user' do
        it { is_expected.not_to be_successful }
      end

      context 'and there is a logged in user' do
        let(:user) { FactoryGirl.create(:user) }

        before do
          login_user(user, current_estates: [estate])
        end

        it { is_expected.to render_template('process_visit') }
      end
    end

    context 'when is unprocessble' do
      before do
        user = FactoryGirl.create(:user)
        login_user(user, current_estates: [estate])
      end
      let!(:visit) { FactoryGirl.create(:booked_visit) }

      it { is_expected.to redirect_to(prison_inbox_path) }
    end
  end

  describe '#update' do
    subject do
      put :update,
        id: visit.id,
        visit: staff_response,
        locale: 'en'
    end

    let(:staff_response) { { slot_granted: visit.slots.first.to_s } }

    it_behaves_like 'disallows untrusted ips'

    context 'and there is no logged in user' do
      it { is_expected.not_to be_successful }
    end

    context 'and there is a logged in user' do
      let(:user) { FactoryGirl.create(:user) }

      before do
        login_user(user, current_estates: [estate])
      end

      context 'when invalid' do
        let(:staff_response) { { slot_granted: '' } }

        it { is_expected.to render_template('process_visit') }
      end

      context 'when valid' do
        let(:staff_response) { { slot_granted: visit.slots.first.to_s, reference_no: 'none' } }

        it { is_expected.to redirect_to(prison_inbox_path) }
      end
    end
  end

  describe '#show' do
    subject { get :show, id: visit.id }

    let(:user) { FactoryGirl.create(:user) }

    it_behaves_like 'disallows untrusted ips'

    context "when logged in" do
      before do
        login_user(user, current_estates: [estate])
      end

      it { is_expected.to render_template('show') }
      it { is_expected.to be_successful }
    end

    context "when logged out" do
      it { is_expected.not_to be_successful }
    end
  end

  describe '#cancel' do
    let(:visit) { FactoryGirl.create(:booked_visit) }
    let(:mailing) { double(Mail::Message, deliver_later: nil) }
    let(:cancellation_reason) { 'slot_unavailable' }

    subject do
      delete :cancel,
        id: visit.id,
        cancellation_reason: cancellation_reason,
        locale: 'en'
    end

    it_behaves_like 'disallows untrusted ips'

    context 'when there is a user logged in' do
      let(:user) { FactoryGirl.create(:user) }

      before do
        login_user(user, current_estates: [estate])
      end

      it { is_expected.to redirect_to(prison_visit_path(visit)) }

      it 'cancels the visit' do
        expect { subject }.
          to change { visit.reload.processing_state }.to('cancelled')
      end

      context 'when the visit is already cancelled' do
        let(:visit) { FactoryGirl.create(:cancelled_visit) }

        it { is_expected.to redirect_to(prison_visit_path(visit)) }
      end

      context 'when there is no cancellation reason' do
        let(:cancellation_reason) { nil }

        it { is_expected.to redirect_to(prison_visit_path(visit)) }
      end
    end

    context "when there isn't a user logged in" do
      it { is_expected.not_to be_successful }
    end
  end

  describe '#confirm_nomis_cancelled' do
    let(:cancellation) { FactoryGirl.create(:cancellation) }
    let(:visit) { cancellation.visit }

    subject { post :nomis_cancelled, id: visit.id }

    it_behaves_like 'disallows untrusted ips'

    context 'when there is a user signed in' do
      let(:user) { FactoryGirl.create(:user) }

      before do
        login_user(user, current_estates: [estate])
      end

      it { is_expected.to redirect_to(prison_inbox_path) }
    end

    context "when signed out" do
      it { is_expected.not_to be_successful }
    end
  end
end
