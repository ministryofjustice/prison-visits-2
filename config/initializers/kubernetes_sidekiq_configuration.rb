if Rails.env.production?
  Sidekiq.configure_server do |config|
    config.redis = {
      url: Rails.configuration.redis_url.to_s,
      network_timeout: 5,
      password: Rails.configuration.redis_password
    }
  end

  Sidekiq.configure_client do |config|
    config.redis = {
      url: Rails.configuration.redis_url.to_s,
      network_timeout: 5,
      password: Rails.configuration.redis_password
    }
  end
end
