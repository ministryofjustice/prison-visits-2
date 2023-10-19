RSpec.shared_examples 'error handling' do
  include_context 'with sendgrid shared tools'

  include_context 'when sendgrid credentials are set'
  include_context 'when sendgrid api responds normally'

  context 'when handling an error' do
    context 'when the API raises an exception' do
      include_context 'when sendgrid api raises an exception'

      it 'rescues, logs the error and returns false' do
        check_error_log_message_contains(/StandardError/)
        expect(PVB::ExceptionHandler)
          .to receive(:capture_exception)
          .with(instance_of(StandardError))

        expect(subject).to be_falsey
      end
    end

    context 'when sendgrid times out' do
      include_context 'when sendgrid times out'

      it 'rescues, logs the error and returns false' do
        check_error_log_message_contains(/Timeout/)
        expect(PVB::ExceptionHandler).not_to receive(:capture_exception)

        expect(subject).to be_falsey
      end
    end

    context 'when the API reports an error' do
      let(:body) { '{"error":"LOL"}' }

      it 'rescues, logs the error and returns false' do
        check_error_log_message_contains(/LOL/)
        expect(subject).to be_falsey
      end
    end

    context 'when the API returns non-JSON' do
      let(:body) { 'Oopsy daisy' }

      it 'rescues, logs the error and returns false' do
        check_error_log_message_contains(/Oopsy daisy/)
        expect(subject).to be_falsey
      end
    end
  end
end

RSpec.shared_examples 'error handling for missing credentials' do
  context 'when sendgrid credentials are not set' do
    include_context 'when sendgrid credentials are not set'

    it 'rescues, logs the error and returns false' do
      expect(subject).to be_falsey
    end
  end
end

RSpec.shared_examples 'API reports email does not exist' do
  let(:message) { 'Email does not exist' }
  let(:body) { "{\"message\": \"#{message}\"}" }

  specify do
    check_error_log_message_contains(/#{message}/)
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

RSpec.shared_examples 'there is a timeout' do
  specify do
    stub_request(:any, %r{.+api\.sendgrid\.com/api/.+\.json}).to_timeout

    expect(subject).to be_falsey
  end
end

RSpec.shared_examples 'sendgrid pool timeouts' do
  specify do
    allow_any_instance_of(ConnectionPool)
      .to receive(:with).and_raise(Timeout::Error)
    expect(subject).to be_falsey
  end
end
