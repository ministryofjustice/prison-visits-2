#!/bin/bash
export RAILS_ENV=production
cd /usr/src/app
case ${DOCKER_STATE} in
create)
    echo "running create"
    bin/rake db:setup db:seed
    ;;
migrate_and_seed)
    echo "running migrate and seed"
    bin/rake db:migrate db:seed
    RETURN_CODE=$?
    while [ $RETURN_CODE -gt 0 ]; do
      sleep 1
      bin/rake db:migrate db:seed
      RETURN_CODE=$?
    done
    ;;
esac
bin/puma -b tcp://0.0.0.0:3000 -d -C config/puma_prod.rb
tail -f /usr/src/app/log/logstash_production.json
