RSpec.shared_examples 'error handling' do
  include_context 'sendgrid shared tools'

  include_context 'sendgrid credentials are set'
  include_context 'sendgrid api responds normally'

  context 'error handling' do
    context 'when the API raises an exception' do
      include_context 'sendgrid api raises an exception'

      it 'rescues, logs the error and returns false' do
        check_error_log_message_contains(/StandardError/)
        expect(subject).to be_falsey
      end
    end

    context 'when the API reports an error' do
      let(:body) { '{"error":"LOL"}' }

      it 'rescues, logs the error and returns false' do
        check_error_log_message_contains(/SendgridToolkit::APIError LOL/)
        expect(subject).to be_falsey
      end
    end

    context 'when the API returns non-JSON' do
      let(:body) { 'Oopsy daisy' }

      it 'rescues, logs the error and returns false' do
        check_error_log_message_contains(/JSON::ParserError.+Oopsy daisy/)
        expect(subject).to be_falsey
      end
    end
  end
end

RSpec.shared_examples 'error handling for missing credentials' do
  context 'sendgrid credentials are not set' do
    include_context 'sendgrid credentials are not set'

    it 'rescues, logs the error and returns false' do
      check_error_log_message_contains(/SendgridToolkit::NoAPIUserSpecified/)
      expect(subject).to be_falsey
    end

    it 'does not talk to sendgrid' do
      expect(HTTParty).to receive(:post).never { subject }
    end
  end
end

RSpec.shared_examples 'API reports email does not exist' do
  let(:body) { '{"message": "Email does not exist"}' }

  specify do
    check_error_log_message_contains(/EmailDoesNotExist/)
    expect(subject).to be_falsey
  end
end

RSpec.shared_examples 'API reports success' do
  let(:body) { '{"message": "success"}' }

  specify do
    expect(subject).to be_truthy
  end
end

RSpec.shared_examples 'there is nothing to report' do
  specify do
    expect(logger).not_to receive(:error)
    expect(subject).to be_falsey
  end
end

RSpec.shared_examples 'there is something to report' do
  specify do
    expect(subject).to be_truthy
  end
end

RSpec.shared_examples 'timeout handling' do
  specify do
    expect(Timeout).
      to receive(:timeout).
      with(described_class::DEFAULT_TIMEOUT).
      and_raise(Timeout::Error)

    expect(subject).to be_falsey
  end
end
