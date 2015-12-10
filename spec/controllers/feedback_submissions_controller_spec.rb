require 'rails_helper'

RSpec.describe FeedbackSubmissionsController, type: :controller do
  include ActiveJobHelper

  before do
    allow(ZendeskTicketsJob).to receive(:perform_later)
  end

  context 'new' do
    it 'responds with success' do
      get :new
      expect(response).to be_success
    end

    it 'renders the new template' do
      get :new
      expect(response).to render_template('new')
    end
  end

  context 'create' do
    context 'with a successful feedback submission' do
      let(:feedback_params) {
        { email_address: 'test@maildrop.dsd.io', body: 'feedback', referrer: 'ref' }
      }

      it 'renders the create template' do
        post :create, feedback_submission: feedback_params
        expect(response).to render_template('create')
      end

      it 'sends to ZenDesk' do
        expect(ZendeskTicketsJob).to receive(:perform_later).once do |feedback|
          expect(feedback.email_address).to eq('test@maildrop.dsd.io')
          expect(feedback.body).to eq('feedback')
        end
        post :create, feedback_submission: feedback_params
      end
    end

    context 'with no body entered' do
      let(:feedback_params) {
        { email_address: 'test@maildrop.dsd.io', body: '', referrer: 'ref' }
      }

      it 'responds with success' do
        post :create, feedback_submission: feedback_params
        expect(response).to be_success
      end

      it 'does not send to ZenDesk' do
        expect(ZendeskTicketsJob).to receive(:perform_later).never
        post :create, feedback_submission: feedback_params
      end

      it 're-renders the new template' do
        post :create, feedback_submission: feedback_params
        expect(response).to render_template('new')
      end
    end
  end
end
