#!/bin/bash
export RAILS_ENV=production
cd /usr/src/app
case ${DOCKER_STATE} in
create)
    echo "running create"
    bundle exec rake db:create db:schema:load db:seed
    ;;
seed)
    echo "running seed"
    bundle exec rake db:schema:load db:seed
    ;;
migrate)
    echo "running migrate"
    bundle exec rake db:schema:load
    ;;
esac
bundle exec rake assets:precompile
REDIS_URL="redis://redis:6379" bundle exec sidekiq -d -l /var/log/sidekiq.log --environment production
bundle exec rails server --binding 0.0.0.0
