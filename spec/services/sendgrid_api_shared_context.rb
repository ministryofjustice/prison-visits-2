# frozen_string_literal: true
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
  # SendgridApi is a singleton, since we are testing the disabling behaviour we
  # want to bypass the singletong so that state changes don't leak to other
  # specs
  let(:instance) {
    client = SendgridApi.new_client(api_user, api_key)
    pool = ConnectionPool.new(size: 1, timeout: 1, &client)

    obj = described_class.send(:new, pool)

    # Configuring the pool enables the clients which we do in the Rails
    # initializers based on a configuration flag.
    #
    # Expected behaviour is for the api to not be enabled if the credentials are
    # missing.
    obj.disable unless api_user && api_key
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
        'email'     => 'test@example.com'
      )).
      to_return(status: 200, body: body, headers: {})
  end
end

RSpec.shared_context 'sendgrid api raises an exception' do
  before do
    stub_request(:any, %r{.*api\.sendgrid\.com/api/.+\.json}).
      to_raise(StandardError)
  end
end

RSpec.shared_context 'sendgrid timeout' do
  before do
    stub_request(:any, %r{.*api\.sendgrid\.com/api/.+\.json}).
      to_raise(Excon::Errors::Timeout)
  end
end
