require 'rails_helper'

RSpec.shared_context 'sendgrid shared tools' do
  let(:logger) { Rails.logger }
  let(:body) { '[]' }

  def check_error_log_message_contains(regexp)
    expect(logger).to receive(:error).
      with(regexp)
  end
end

RSpec.shared_context 'sendgrid credentials are set' do
  before do
    allow(Rails.configuration).to receive(:sendgrid_api_user).
      and_return('test_smtp_username')

    allow(Rails.configuration).to receive(:sendgrid_api_key).
      and_return('test_smtp_password')
  end
end

RSpec.shared_context 'sendgrid credentials are not set' do
  before do
    allow(Rails.configuration).to receive(:sendgrid_api_user).
      and_return(nil)

    allow(Rails.configuration).to receive(:sendgrid_api_key).
      and_return(nil)
  end
end

RSpec.shared_context 'sendgrid api responds normally' do
  before do
    stub_request(:any, %r{.+sendgrid\.example\.com/api/.+\.json}).
      with(query: hash_including(
        'api_key'   => 'test_smtp_password',
        'api_user'  => 'test_smtp_username',
        'email'     => 'test@example.com')).
      to_return(status: 200, body: body, headers: {})
  end
end

RSpec.shared_context 'sendgrid api raises an exception' do
  before do
    stub_request(:any, %r{.*sendgrid\.example\.com/api/.+\.json}).
      to_raise(StandardError)
  end
end
