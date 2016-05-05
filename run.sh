#!/bin/bash
export RAILS_ENV=production
cd /usr/src/app
case ${DOCKER_STATE} in
create)
    echo "running create"
    bundle exec rake db:setup db:seed
    ;;
migrate_and_seed)
    echo "running migrate and seed"
    bundle exec rake db:migrate db:seed
    ;;
esac
bundle exec puma -b tcp://0.0.0.0:3000 -d -C config/puma_prod.rb
tail -f /usr/src/app/log/logstash_production.json
