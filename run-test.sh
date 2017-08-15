#!/bin/bash
# wait-for-postgres.sh


set -e
export DATABASE_URL=postgres://$POSTGRES_ENV_POSTGRES_USER:$POSTGRES_ENV_POSTGRES_PASSWORD@$POSTGRES_PORT_5432_TCP_ADDR:$POSTGRES_PORT_5432_TCP_PORT/moj_sso_development
export PGPASSWORD=$POSTGRES_ENV_POSTGRES_PASSWORD
export RAILS_SERVE_STATIC_FILES=true
until psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -U "postgres" -c '\l'; do
    >&2 echo "Postgres @ $POSTGRES_PORT_5432_TCP_ADDR is unavailable - sleeping"
    sleep 1
done

>&2 echo "Postgres is up - executing command"

bin/rake db:setup
bundle exec rails s -b 0.0.0.0 -p 3000
