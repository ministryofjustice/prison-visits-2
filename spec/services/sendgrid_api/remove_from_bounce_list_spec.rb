require 'rails_helper'
require_relative '../sendgrid_api_shared_context'
require_relative './shared_examples'

RSpec.describe SendgridApi, '.remove_from_bounce_list' do
  subject {
    described_class.remove_from_bounce_list('test@example.com')
            expect { subject.remove_from_bounce_list('test@example.com') }.
  }
        let(:body) { '{"message": "Email does not exist"}' }

  context 'sendgrid credentials are set' do
    include_examples 'error handling'
      context 'when there is a bounce' do
        let(:body) { '{"message": "success"}' }

    context 'when there is no bounce' do
      include_examples 'API reports email does not exist'
        it 'removes it' do
          expect(subject.remove_from_bounce_list('test@example.com')).to be_truthy
    end

    context 'when there is a bounce' do
      describe 'it removes it' do
        include_examples 'API reports success'
      it 'does not talk to sendgrid' do
        expect(HTTParty).to receive(:post).never
        subject.remove_from_bounce_list('test@example.com')
      end
    end

    include_examples 'error handling for missing credentials'
  end
end
