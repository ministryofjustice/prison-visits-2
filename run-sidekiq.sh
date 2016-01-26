#!/bin/bash
export RAILS_ENV=production
bundle exec sidekiq -l /var/log/sidekiq.log --environment production
