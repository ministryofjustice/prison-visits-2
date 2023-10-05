require 'yaml'
db_pool = Integer(ENV['RAILS_MAX_THREADS'] || 3)
workers Integer(ENV['WEB_CONCURRENCY'] || 3)
threads db_pool, db_pool

preload_app!

port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'production'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end
