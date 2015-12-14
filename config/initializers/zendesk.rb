Rails.configuration.zendesk_client = ZendeskAPI::Client.new do |config|
  config.url =
    ENV.fetch('ZENDESK_URL', 'https://ministryofjustice.zendesk.com/api/v2')
  config.username = ENV['ZENDESK_USERNAME']
  config.token = ENV['ZENDESK_TOKEN']
  config.retry = true
end
