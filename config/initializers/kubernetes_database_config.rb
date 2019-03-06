if Rails.env.production? && Rails.configuration.kubernetes_deployment
  ActiveRecord::Base.establish_connection(
    url: ENV['DATABASE_URL'],
    database: 'pvb2_production'
  )
end
