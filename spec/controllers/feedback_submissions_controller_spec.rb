require 'rails_helper'

RSpec.describe FeedbackSubmissionsController, type: :controller do
  include ActiveJobHelper

  before do
    allow(ZendeskTicketsJob).to receive(:perform_later)
  end

  context 'new' do
    let(:params) { { locale: 'en' } }
    it 'responds with success' do
      get :new, params
      expect(response).to be_success
    end

    it 'renders the new template' do
      get :new, params
      expect(response).to render_template('new')
    end
  end

  context 'create' do
    context 'with a successful feedback submission' do
      let(:params) {
        {
          feedback_submission: {
            email_address: 'test@maildrop.dsd.io', body: 'feedback', referrer: 'ref'
          },
          locale: 'en'
        }
      }

      it 'renders the create template' do
        post :create, params
        expect(response).to render_template('create')
      end

      it 'sends to ZenDesk' do
        expect(ZendeskTicketsJob).to receive(:perform_later).once do |feedback|
          expect(feedback.email_address).to eq('test@maildrop.dsd.io')
          expect(feedback.body).to eq('feedback')
        end
        post :create, params
      end
    end

    context 'with no body entered' do
      let(:params) {
        {
          feedback_submission: {
            email_address: 'test@maildrop.dsd.io', body: '', referrer: 'ref'
          },
          locale: 'en'
        }
      }

      it 'responds with success' do
        post :create, params
        expect(response).to be_success
      end

      it 'does not send to ZenDesk' do
        expect(ZendeskTicketsJob).to receive(:perform_later).never
        post :create, params
      end

      it 're-renders the new template' do
        post :create, params
        expect(response).to render_template('new')
      end
    end
  end
end
