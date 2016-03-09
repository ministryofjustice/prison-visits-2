require 'rails_helper'

RSpec.shared_context 'sendgrid shared tools' do
  let(:logger) { Rails.logger }
  let(:body) { '[]' }

  def check_error_log_message_contains(regexp)
    expect(logger).to receive(:error).
      with(regexp)
  end
end

RSpec.shared_context 'sendgrid instance' do
  let(:instance) {
    obj = described_class.new(api_user: api_user,
                              api_key: api_key,
                              timeout: 1)
    # Configuring the pool enables the clients which we do in the Rails
    # initializers based on a configuration flag.
    #
    # Expected behaviour is for the api to not be enabled if the credentials are
    # missing.
    obj.configure_pool(pool_size: 1, pool_timeout: 1) if api_user && api_key
    obj
  }
end

RSpec.shared_context 'sendgrid credentials are set' do
  let(:api_user) { 'test_smtp_username' }
  let(:api_key) { 'test_smtp_password' }
end

RSpec.shared_context 'sendgrid credentials are not set' do
  let(:api_user) { nil }
  let(:api_key) { nil }
end

RSpec.shared_context 'sendgrid api responds normally' do
  before do
    stub_request(:any, %r{.+api\.sendgrid\.com/api/.+\.json}).
      with(query: hash_including(
        'api_key'   => 'test_smtp_password',
        'api_user'  => 'test_smtp_username',
        'email'     => 'test@example.com')).
      to_return(status: 200, body: body, headers: {})
  end
end

RSpec.shared_context 'sendgrid api raises an exception' do
  before do
    stub_request(:any, %r{.*api\.sendgrid\.com/api/.+\.json}).
      to_raise(StandardError)
  end
end
