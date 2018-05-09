module ZendeskClient
  def client
    @client ||= ZendeskAPI::Client.new do |config|
      config.url = Rails.configuration.zendesk_url
      config.username = Rails.configuration.zendesk_user
      config.token = Rails.configuration.zendesk_token
      config.retry = true
    end
  end
end
