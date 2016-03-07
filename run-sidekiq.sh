#!/bin/bash
export RAILS_ENV=production
bundle exec rackup sidekiq-admin.ru -p 3000 -E production -o 0.0.0.0 &
bundle exec sidekiq -l /var/log/sidekiq.log --environment production
