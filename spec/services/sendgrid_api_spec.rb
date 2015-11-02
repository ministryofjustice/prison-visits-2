require 'rails_helper'

RSpec.describe SendgridApi do
  subject { described_class.new }

  context 'with sendgrid configured' do
    around do |example|
      smtp_settings = Rails.configuration.action_mailer.smtp_settings
      Rails.configuration.action_mailer.smtp_settings = {
        user_name: 'test_smtp_username',
        password: 'test_smtp_password'
      }
      example.run
      Rails.configuration.action_mailer.smtp_settings = smtp_settings
    end

    describe '.remove_from_bounce_list' do
      let(:body) { nil }

      before do
        stub_request(:post, 'https://api.sendgrid.com/api/bounces.delete.json').
          with(query: hash_including(
            'api_key'   => 'test_smtp_password',
            'api_user'  => 'test_smtp_username',
            'email'     => 'test@example.com')).
          to_return(status: 200, body: body, headers: {})
      end

      context 'error handling' do
        context 'when the API raises an exception' do
          before do
            stub_request(:post, 'https://api.sendgrid.com/api/bounces.delete.json').
              with(query: hash_including(
                'api_key'   => 'test_smtp_password',
                'api_user'  => 'test_smtp_username',
                'email'     => 'test@example.com')).
              to_raise(StandardError)
          end

          specify do
            expect { subject.remove_from_bounce_list('test@example.com') }.
              to raise_error(StandardError)
          end
        end

        context 'when the API reports an error' do
          let(:body) { '{"error":"LOL"}' }

          specify do
            expect { subject.remove_from_bounce_list('test@example.com') }.
              to raise_error(SendgridToolkit::APIError)
          end
        end

        context 'when the API returns non-JSON' do
          let(:body) { 'Oopsy daisy' }

          specify do
            expect { subject.remove_from_bounce_list('test@example.com') }.
              to raise_error(JSON::ParserError)
          end
        end
      end

      context 'when there is no bounce' do
        let(:body) { '{"message": "Email does not exist"}' }

        specify do
          expect(subject.remove_from_bounce_list('test@example.com')).to be_falsey
        end
      end

      context 'when there is a bounce' do
        let(:body) { '{"message": "success"}' }

        it 'removes it' do
          expect(subject.remove_from_bounce_list('test@example.com')).to be_truthy
        end
      end
    end

    describe '.remove_from_spam_list' do
      let(:body) { nil }

      before do
        stub_request(:post, 'https://api.sendgrid.com/api/spamreports.delete.json').
          with(query: hash_including(
            'api_key'   => 'test_smtp_password',
            'api_user'  => 'test_smtp_username',
            'email'     => 'test@example.com')).
          to_return(status: 200, body: body, headers: {})
      end

      context 'error handling' do
        context 'when the API raises an exception' do
          before do
            stub_request(:post, 'https://api.sendgrid.com/api/spamreports.delete.json').
              with(query: hash_including(
                'api_key'   => 'test_smtp_password',
                'api_user'  => 'test_smtp_username',
                'email'     => 'test@example.com')).
              to_raise(StandardError)
          end

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

      context 'when there is no bounce' do
        let(:body) { '{"message": "Email does not exist"}' }

        specify do
          expect(subject.remove_from_spam_list('test@example.com')).to be_falsey
        end
      end

      context 'when there is a bounce' do
        let(:body) { '{"message": "success"}' }

        it 'removes it' do
          expect(subject.remove_from_spam_list('test@example.com')).to be_truthy
        end
      end
    end
  end

  context 'without sendgrid configured' do
    around do |example|
      smtp_settings = Rails.configuration.action_mailer.smtp_settings
      Rails.configuration.action_mailer.smtp_settings = {}
      example.run
      Rails.configuration.action_mailer.smtp_settings = smtp_settings
    end

    describe '.remove_from_bounce_list' do
      specify do
        expect(subject.remove_from_bounce_list('test@example.com')).to be_falsey
      end

      it 'does not talk to sendgrid' do
        expect(HTTParty).to receive(:post).never
        subject.remove_from_bounce_list('test@example.com')
      end
    end

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
