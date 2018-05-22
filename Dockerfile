FROM ministryofjustice/ruby:2.5.1-webapp-onbuild

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" >  /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# Update openssl & ca-certificates so that communication with signon can take place
# (TODO: Remove this when base container has been updated)
RUN apt-get update && \
    apt-get install -y ca-certificates openssl postgresql-client-9.4 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV UNICORN_PORT 3000
EXPOSE $UNICORN_PORT

RUN gem update bundler --no-doc

RUN RAILS_ENV=production PUBLIC_SERVICE_URL=foo STAFF_SERVICE_URL=foo SECRET_KEY_BASE=foo bin/rake assets:precompile --trace

ENTRYPOINT ["./run.sh"]
