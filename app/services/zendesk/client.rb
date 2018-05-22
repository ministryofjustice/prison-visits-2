module Zendesk
  class Client
    include Singleton

    attr_reader :client

    def initialize
      @client = ZendeskAPI::Client.new do |config|
        config.url = Rails.configuration.zendesk_url
        config.username = Rails.configuration.zendesk_username
        config.token = Rails.configuration.zendesk_token
        config.retry = true
      end
    end
  end
end
