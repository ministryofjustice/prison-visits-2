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
REDIS_URL="redis://redis:6379" bundle exec sidekiq -d -l /var/log/sidekiq.log --environment production
bundle exec rails server --binding 0.0.0.0
