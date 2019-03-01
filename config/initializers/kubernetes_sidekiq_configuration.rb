if Rails.env.production? && Rails.configuration.kubernetes_deployment
  Sidekiq.configure_server do |config|
    config.redis = {
      url: "rediss://#{Rails.configuration.redis_url}:6379",
      network_timeout: 5,
      password: Rails.configuration.redis_password
    }
  end

  Sidekiq.configure_client do |config|
    config.redis = {
      url: "rediss://#{Rails.configuration.redis_url}:6379",
      network_timeout: 5,
      password: Rails.configuration.redis_password
    }
  end
end
