require 'rails_helper'
require_relative '../untrusted_examples'

RSpec.describe Prison::VisitsController, type: :controller do
  let(:visit) { FactoryGirl.create(:visit) }
  let(:estate) { visit.prison.estate }


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
      let(:user)                { create(:user) }
      let(:nowish)              { Time.zone.now }
      let(:processing_time_key) { "processing_time-#{visit.id}-#{user.id}" }

      before do
        login_user(user, current_estates: [estate])
        request.cookies[processing_time_key] = nowish - 2.minutes
      end

      context 'when invalid' do
        let(:staff_response) { { slot_granted: '' } }

        it { is_expected.to render_template('show') }
      end

      context 'when valid' do
        let(:staff_response) { { slot_granted: visit.slots.first.to_s, reference_no: 'none' } }
        let(:google_tracker) { instance_double(GATracker) }

        before do
          expect(GATracker).
            to receive(:new).and_return(google_tracker)
          expect(google_tracker).
            to receive(:send_event)
        end
        it { is_expected.to redirect_to(prison_inbox_path) }

      end

      context 'with book to nomis related error' do
        let(:staff_response) { { slot_granted: visit.slots.first.to_s, reference_no: 'none' } }
        let(:booking_response) do
          instance_double(BookingResponse, success?: false,
                                           already_processed?: false,
                                           message: booking_response_message)
        end

        before do
          mock_service_with(BookingResponse, booking_response)
        end

        context 'when there is an api error' do
          let(:booking_response_message) { BookingResponse::NOMIS_API_ERROR }

          it 'sets the flash message' do
            subject
            expect(flash[:alert]).to match("We can't connect to NOMIS right now.")
          end
        end

        context 'when there is an api validation' do
          let(:booking_response_message) { BookingResponse::NOMIS_VALIDATION_ERROR }

          it 'sets the flash message' do
            subject
            expect(flash[:alert]).to match("This visit wasn't booked.")
          end
        end
      end
    end
  end

  describe '#show' do

    let(:nowish) { Time.zone.now }
    let(:user)   { create(:user) }

    it_behaves_like 'disallows untrusted ips'

    context "when logged in" do

      before do
        travel_to nowish do
          login_user(user, current_estates: [estate])
          get :show, id: visit.id
        end
      end

      it { expect(response).to render_template('show') }
      it { expect(response).to be_successful }

      context 'with a processable visit' do
        let(:processing_time_key) { "processing_time-#{visit.id}-#{user.id}"  }
        let(:parsed_cookie)       { cookies[processing_time_key] }

        it "sets the visit processing time cookie" do
          expect(parsed_cookie).to eq(nowish.to_i)
        end
      end
    end

    context "when logged out" do

      before { get :show, id: visit.id }

      it { expect(response).not_to be_successful }
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
