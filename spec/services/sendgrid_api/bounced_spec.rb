require 'rails_helper'
require_relative '../sendgrid_api_shared_context'

RSpec.describe SendgridApi, '.bounced?' do
  context 'with sendgrid configured' do
    let(:body) { '[]' }
    include_context 'sendgrid is configured'
    include_context 'sendgrid api responds normally'

    context 'error handling' do
      context 'when the API raises an exception' do
        include_context 'sendgrid api raises an exception'

        specify do
          expect { subject.bounced?('test@example.com') }.
            to raise_error(StandardError)
        end
      end

      context 'when the API reports an error' do
        let(:body) { '{"error":"LOL"}' }

        it 'has no bounce' do
          expect(subject.bounced?('test@example.com')).to be_falsey
        end
      end

      context 'when the API returns non-JSON' do
        let(:body) { 'Oopsy daisy' }

        it 'has no bounce' do
          expect(subject.bounced?('test@example.com')).to be_falsey
        end
      end
    end

    context 'when no error' do
      context 'when there is no bounce' do
        let(:body) { '[]' }

        it 'has no bounce' do
          expect(subject.bounced?('test@example.com')).to be_falsey
        end
      end

      context 'when there is a bounce' do
        let(:body) {
          %([
              {
                "status": "4.0.0",
                "created": "2011-09-16 22:02:19",
                "reason": "Unable to resolve MX host example.com",
                "email": "test@example.com"
              }
            ])
        }

        it 'has a bounce' do
          expect(subject.bounced?('test@example.com')).to be_truthy
        end
      end
    end
  end

  context 'without sendgrid configured' do
    include_context 'sendgrid is not configured'

    describe '.bounced?' do
      it 'never says that the email has bounced' do
        expect(subject.bounced?('test@example.com')).to be_falsey
      end

      it 'does not talk to sendgrid' do
        expect(HTTParty).to receive(:post).never
        subject.bounced?('test@example.com')
      end
    end
  end
end
