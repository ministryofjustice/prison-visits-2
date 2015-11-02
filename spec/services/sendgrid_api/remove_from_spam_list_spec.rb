require 'rails_helper'
require_relative '../sendgrid_api_shared_context'

RSpec.describe SendgridApi, '.remove_from_spam_list' do
  subject { described_class.new }

  context 'with sendgrid configured' do
    let(:body) { nil }
    include_context 'sendgrid is configured'
    include_context 'sendgrid api responds normally'

    context 'error handling' do
      describe '.remove_from_spam_list' do
        let(:body) { nil }

        context 'error handling' do
          context 'when the API raises an exception' do
            include_context 'sendgrid api raises an exception'

            specify do
              expect { subject.remove_from_spam_list('test@example.com') }.
                to raise_error(StandardError)
            end
          end

          context 'when the API reports an error' do
            let(:body) { '{"error":"LOL"}' }

            specify do
              expect { subject.remove_from_spam_list('test@example.com') }.
                to raise_error(SendgridToolkit::APIError)
            end
          end

          context 'when the API returns non-JSON' do
            let(:body) { 'Oopsy daisy' }

            specify do
              expect { subject.remove_from_spam_list('test@example.com') }.
                to raise_error(JSON::ParserError)
            end
          end
        end

        context 'when email does not exist' do
          let(:body) { '{"message": "Email does not exist"}' }

          specify do
            expect(subject.remove_from_spam_list('test@example.com')).to be_falsey
          end
        end

        context 'when email exists' do
          let(:body) { '{"message": "success"}' }

          it 'removes it' do
            expect(subject.remove_from_spam_list('test@example.com')).to be_truthy
          end
        end
      end
    end
  end

  context 'without sendgrid configured' do
    include_context 'sendgrid is not configured'
    describe '.remove_from_spam_list' do
      specify do
        expect(subject.remove_from_spam_list('test@example.com')).to be_falsey
      end

      it 'does not talk to sendgrid' do
        expect(HTTParty).to receive(:post).never
        subject.remove_from_spam_list('test@example.com')
      end
    end
  end
end
