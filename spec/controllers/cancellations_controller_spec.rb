require 'rails_helper'

RSpec.describe CancellationsController, type: :controller do
  describe 'create' do
    context 'when confirm is checked' do
      let(:params) { { id: visit.id, confirmed: '1', locale: 'en' } }

      context 'when the visit has been requested' do
        let(:visit) { create(:visit) }

        it 'withdraws the request' do
          post :create, params
          expect(visit.reload).to be_withdrawn
        end

        it 'redirects to the visit page' do
          post :create, params
          expect(response).to redirect_to(visit_path(visit, locale: 'en'))
        end
      end

      context 'when the request has been withdrawn' do
        let(:visit) { create(:withdrawn_visit) }

        it 'does not change the visit' do
          post :create, params
          expect(visit.reload).to be_withdrawn
        end

        it 'redirects to the visit page' do
          post :create, params
          expect(response).to redirect_to(visit_path(visit, locale: 'en'))
        end
      end

      context 'when the request has been accepted' do
        let(:visit) { create(:booked_visit) }

        it 'cancels the visit' do
          post :create, params
          expect(visit.reload).to be_cancelled
        end

        it 'redirects to the visit page' do
          post :create, params
          expect(response).to redirect_to(visit_path(visit, locale: 'en'))
        end
      end

      context 'when the request has been rejected' do
        let(:visit) { create(:rejected_visit) }

        it 'raises StateMachines::InvalidTransition' do
          expect { post :create, params }.
            to raise_exception(StateMachines::InvalidTransition)
        end
      end

      context 'when the booking has been cancelled' do
        let(:visit) { create(:cancelled_visit) }

        it 'does not change the visit' do
          post :create, params
          expect(visit.reload).to be_cancelled
        end

        it 'redirects to the visit page' do
          post :create, params
          expect(response).to redirect_to(visit_path(visit, locale: 'en'))
        end
      end
    end

    context 'when confirm is not checked' do
      let(:visit) { create(:visit) }
      let(:params) { { id: visit.id, locale: 'en' } }

      it 'does not change the visit' do
        post :create, params
        expect(visit.reload).to be_requested
      end

      it 'redirects to the visit page' do
        post :create, params
        expect(response).to redirect_to(visit_path(visit, locale: 'en'))
      end
    end
  end
end
