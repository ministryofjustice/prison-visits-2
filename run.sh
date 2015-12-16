#!/bin/bash
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
RAILS_ENV=production bundle exec import:all assets:precompile
bundle exec rails server --binding 0.0.0.0
