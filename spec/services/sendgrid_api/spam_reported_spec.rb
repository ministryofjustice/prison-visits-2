require 'rails_helper'
require_relative '../sendgrid_api_shared_context'

RSpec.describe SendgridApi::SpamReports, '.spam_reported?' do
  subject { described_class.new }

  context 'with sendgrid configured' do
    let(:body) { '[]' }
    include_context 'sendgrid is configured'
    include_context 'sendgrid api responds normally'

    context 'error handling' do
      context 'when the API raises an exception' do
        include_context 'sendgrid api raises an exception'

        specify do
          expect { subject.spam_reported?('test@example.com') }.
            to raise_error(StandardError)
        end
      end

      context 'when the API reports an error' do
        let(:body) { '{"error":"LOL"}' }

        it 'has no spam report' do
          expect(subject.spam_reported?('test@example.com')).to be_falsey
        end
      end

      context 'when the API returns non-JSON' do
        let(:body) { 'Oopsy daisy' }

        it 'has no spam report' do
          expect(subject.spam_reported?('test@example.com')).to be_falsey
        end
      end
    end

    context 'when no error' do
      context 'when there is no spam report' do
        let(:body) { '[]' }

        it 'has no spam report' do
          expect(subject.spam_reported?('test@example.com')).to be_falsey
        end
      end

      context 'when there is a spam report' do
        let(:body) {
          %([
              {
                "ip": "174.36.80.219",
                "email": "test@example.com",
                "created": "2009-12-06 15:45:08"
              }
            ])
        }

        it 'has a spam report' do
          expect(subject.spam_reported?('test@example.com')).to be_truthy
        end
      end
    end
  end

  context 'without sendgrid configured' do
    include_context 'sendgrid is not configured'

    it 'never says that the email address has been reported for spam' do
      expect(subject.spam_reported?('test@example.com')).to be_falsey
    end

    it 'does not talk to sendgrid' do
      expect(HTTParty).to receive(:post).never
      subject.spam_reported?('test@example.com')
    end
  end
end
