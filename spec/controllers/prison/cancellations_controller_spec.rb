require "rails_helper"

RSpec.describe Prison::CancellationsController do
  describe '#create' do
    let(:visit)   { create(:booked_visit) }
    let(:estate)  { visit.prison.estate }
    let(:mailing) { double(Mail::Message, deliver_later: nil) }
    let(:cancellation_reasons) { ['slot_unavailable'] }

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

    it_behaves_like 'disallows untrusted ips'

    context 'when there is a user logged in' do
      before do
        login_user(create(:user), current_estates: [estate])
      end

      it { is_expected.to redirect_to(prison_visit_path(visit)) }

      it 'cancels the visit' do
        expect { subject }.
          to change { visit.reload.processing_state }.to('cancelled')
      end

      context 'when the visit is already cancelled' do
        let(:visit) { create(:cancelled_visit) }

        it 'redirect to the visit show page setting the already cancelled flash message' do
          is_expected.to redirect_to(prison_visit_path(visit))
          expect(flash.notice).to eq("The visit is no longer cancellable")
        end
      end
    end

    context "when there isn't a user logged in" do
      it { is_expected.not_to be_successful }
    end
  end
end
