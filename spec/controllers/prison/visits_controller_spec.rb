require 'rails_helper'
require_relative '../untrusted_examples'

RSpec.describe Prison::VisitsController, type: :controller do
  let(:visit) { FactoryGirl.create(:visit) }
  let(:estate) { visit.prison.estate }

  describe '#process_visit' do
<<<<<<< HEAD
    let(:nowish) { 1.day.ago }

    subject { response }
=======
    let(:nowish) { Time.zone.now }
    subject do
      travel_to nowish do
        get :process_visit, id: visit.id, locale: 'en'
      end
    end
>>>>>>> record processing start time by logged in user

    context 'when is processable' do
      context 'and there is no logged in user' do
        before do
          get :process_visit, id: visit.id, locale: 'en'
        end

        it { is_expected.not_to be_successful }
      end

      context 'and there is a logged in user' do
        let(:user)                { create(:user) }
        let(:processing_time_key) { "processing_time-#{visit.id}-#{user.id}"  }
        let(:parsed_cookie)       { cookies[processing_time_key] }

        before do
          travel_to nowish do
            login_user(user, current_estates: [estate])
            get :process_visit, id: visit.id, locale: 'en'
          end
        end

        it { is_expected.to render_template('process_visit') }
<<<<<<< HEAD

        it 'sets the processing time cookie' do
          expect(parsed_cookie).to eq(nowish.to_i)
        end

        describe 'when re-displaying the page' do
          it 'does not override the start time' do
            expect {
              get :process_visit, id: visit.id, locale: 'en'
            }.not_to change { cookies[processing_time_key] }
          end
        end
=======
        it {
          ap cookies
          expect(JSON.parse(cookies[described_class::PROCESSING_TIME_KEY])).
            to eq({ processing_by: user.id, started_at: nowish.to_i })
        }
>>>>>>> record processing start time by logged in user
      end
    end

    context 'when is unprocessble' do
      before do
        login_user(create(:user), current_estates: [estate])
        get :process_visit, id: visit.id, locale: 'en'
      end
      let!(:visit) { create(:booked_visit) }

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
