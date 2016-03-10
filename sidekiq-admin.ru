require 'sidekiq'

Sidekiq.configure_client do |config|
  config.redis = { :size => 1 }
end

require 'sidekiq/web'
use Rack::Session::Cookie, :secret => ENV.fetch('SESSION_SECRET_KEY')
Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
end if Rails.env.production?
run Sidekiq::Web
