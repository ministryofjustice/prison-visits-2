if Rails.env.production? && Rails.configuration.kubernetes_deployment
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
end
