#!/bin/bash
export RAILS_ENV=production
bin/sidekiq --daemon -l /var/log/sidekiq.log --environment production

tail -f /usr/src/app/log/logstash_production.json
