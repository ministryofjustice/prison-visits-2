module Zendesk
  class PVBClient
    include Singleton

    attr_reader :pool

    def initialize
      pool_size = Rails.configuration.connection_pool_size
      @pool = ConnectionPool.new(size: pool_size, timeout: 1) do
        ZendeskAPI::Client.new do |config|
          config.url = Rails.configuration.zendesk_url
          config.username = Rails.configuration.zendesk_username
          config.token = Rails.configuration.zendesk_token
          config.retry = true
        end
      end
    end
  end
end
