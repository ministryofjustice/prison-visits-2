require 'rails_helper'
require_relative '../untrusted_examples'

RSpec.describe Prison::FeedbacksController, type: :controller do
  describe '#new' do
    subject { get :new }
    it_behaves_like 'disallows untrusted ips'

    before do
      login_user(
        FactoryGirl.create(:user),
        current_estates: [FactoryGirl.create(:estate)]
      )
    end

    it { is_expected.to be_successful }
  end

  describe '#create' do
    subject { post :create, feedback_submission: feedback_params }

    let(:feedback_params) do
      {
        body: body,
        email_address: 'john@example.com',
        prison_id: prison.id,
        referrer: 'somewhere'
      }
    end
    let(:body) { 'My comment' }
    let(:prison) { FactoryGirl.create(:prison) }

    it_behaves_like 'disallows untrusted ips'

    context 'is successful' do
      it 'creates a feedback submission and enqueues it' do
        expect(ZendeskTicketsJob).to receive(:perform_later).once do |feedback|
          expect(feedback.email_address).to eq('john@example.com')
          expect(feedback.body).to eq(body)
          expect(feedback.submitted_by_staff).to eq(true)
        end

        expect { subject }.to change { FeedbackSubmission.count }.by(1)
      end

      it { is_expected.to redirect_to(prison_inbox_path) }
    end

    context 'is unsuccessful' do
      let(:body) { nil }

      it { is_expected.to render_template('new') }
    end
  end
end
