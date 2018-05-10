url = ENV.fetch('ZENDESK_URL', 'https://ministryofjustice.zendesk.com/api/v2')
username = ENV['ZENDESK_USERNAME']
token = ENV['ZENDESK_TOKEN']

if url && username && token
  Rails.configuration.zendesk_client = ZendeskAPI::Client.new do |config|
    config.url = url
    config.username = username
    config.token = token
    config.retry = true
  end
else
  # (Rails logger is not initialized yet)
  STDOUT.puts '[WARN] Zendesk is not configured'
end
