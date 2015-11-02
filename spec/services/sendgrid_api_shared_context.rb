RSpec.shared_context 'sendgrid is configured' do
  around do |example|
    smtp_settings = Rails.configuration.action_mailer.smtp_settings
    Rails.configuration.action_mailer.smtp_settings = {
      user_name: 'test_smtp_username',
      password: 'test_smtp_password'
    }
    example.run
    Rails.configuration.action_mailer.smtp_settings = smtp_settings
  end
end

RSpec.shared_context 'sendgrid is not configured' do
  around do |example|
    smtp_settings = Rails.configuration.action_mailer.smtp_settings
    Rails.configuration.action_mailer.smtp_settings = {}
    example.run
    Rails.configuration.action_mailer.smtp_settings = smtp_settings
  end
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
