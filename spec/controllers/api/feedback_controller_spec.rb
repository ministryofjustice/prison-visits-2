require 'rails_helper'

RSpec.describe Api::FeedbackController, type: :controller do
  include ActiveJobHelper

  before do
    set_configuration_with(:zendesk_url, 'https://zendesk_api.com')
    allow(ZendeskTicketsJob).to receive(:perform_later)
  end

  let(:parsed_body) {
    JSON.parse(response.body)
  }

  describe "#create" do
    let(:body) { 'Feedback body' }
    let(:params) {
      {
        format: :json,
        feedback: {
          body: body,
          email_address: 'john@example.com',
          user_agent: 'browser user agent',
          referrer: 'The referrer',
          prison_id: 'ddd',
          prisoner_number: 'A1234BC',
          prisoner_date_of_birth: '1990-01-01'
        }
      }
    }

    subject(:create) { post :create, params: params }

    it 'creates a new feedback submission' do
      expect { create }.to change(FeedbackSubmission, :count).by(1)
    end

    it 'sends to ZenDesk' do
      expect(ZendeskTicketsJob).to receive(:perform_later).once do |feedback|
        expect(feedback.email_address).to eq('john@example.com')
        expect(feedback.body).to eq(body)
      end
      create!
    end

    it 'renders a 200' do
      expect(subject).to be_ok
      expect(response.body).to eq('{}')
    end

    describe 'with blank body' do
      let(:body) { nil }

      it 'does not send to ZenDesk' do
        expect(ZendeskTicketsJob).not_to receive(:perform_later)
        create!
      end

      it 'returns an error' do
        expect(subject).to be_unprocessable
        expect(parsed_body['message']).to eq("Body is required")
      end
    end
  end
end
