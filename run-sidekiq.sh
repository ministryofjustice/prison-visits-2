#!/bin/bash
export RAILS_ENV=production
bundle exec sidekiq -d -l /var/log/sidekiq.log --environment production
