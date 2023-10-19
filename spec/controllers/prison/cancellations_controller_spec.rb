require "rails_helper"

RSpec.describe Prison::CancellationsController do
  let(:visit)   { create(:booked_visit) }
  let(:estate)  { visit.prison.estate }
  let(:mailing) { double(Mail::Message, deliver_later: nil) }
  let(:cancellation_reasons) { ['slot_unavailable'] }
  let(:ga_tracker) { double(GATracker) }

  subject do
    post :create, params: {
      visit_id: visit.id,
      cancellation: {
        reasons: cancellation_reasons,
        nomis_cancelled: true
      },
      locale: 'en'
    }
  end

  describe '#create' do
    before do
      allow(GATracker).to receive(:new).and_return(ga_tracker)
    end

    context 'when there is a user logged in' do
      before do
        login_user(create(:user), current_estates: [estate])
      end

      context 'with a cancellable visit' do
        before do
          expect(ga_tracker).to receive(:send_cancelled_visit_event)
        end

        it { is_expected.to redirect_to(prison_visit_path(visit)) }

        it 'cancels the visit' do
          expect { subject }
            .to change { visit.reload.processing_state }.to('cancelled')
        end
      end

      context 'when the visit is already cancelled' do
        let(:visit) { create(:cancelled_visit) }

        before do
          expect(ga_tracker).not_to receive(:send_cancelled_visit_event)
        end

        it 'redirect to the visit show page setting the already cancelled flash message' do
          expect(subject).to redirect_to(prison_visit_path(visit))
          expect(flash.notice).to eq("The visit is no longer cancellable")
        end
      end

      context 'with invalid cancellation reason' do
        let(:cancellation_reasons) { ['invalid cancellation reason'] }

        before do
          login_user(create(:user), current_estates: [estate])

          allow(GATracker).to receive(:new).and_return(ga_tracker)
        end

        it 'redirect to the visit show page setting the already cancelled flash message' do
          expect(subject).to render_template(:new)
          expect(flash.alert).to eq("invalid cancellation reason is not in the list")
        end
      end
    end

    context "when unauthorised" do
      before do
        expect(ga_tracker).not_to receive(:send_cancelled_visit_event)
      end

      it { is_expected.not_to be_successful }
    end
  end
end
