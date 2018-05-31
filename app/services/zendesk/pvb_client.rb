module Zendesk
  class PVBClient
    include Singleton

    def initialize
      self.pool = ConnectionPool.new(size: pool_size, timeout: 1) do
        ZendeskAPI::Client.new do |config|
          config.url = Rails.configuration.zendesk_url
          config.username = Rails.configuration.zendesk_username
          config.token = Rails.configuration.zendesk_token
          config.retry = true
        end
      end
    end

    def request
      pool.with { |client|
        yield client
      }
    end

  private

    attr_accessor :pool

    def pool_size
      Rails.configuration.connection_pool_size
    end
  end
end
