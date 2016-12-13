FROM ministryofjustice/ruby:2.3.0-webapp-onbuild

# Update openssl & ca-certificates so that communication with signon can take place
# (TODO: Remove this when base container has been updated)
RUN apt-get update && \
    apt-get install -y ca-certificates openssl postgresql-client-9.4 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY config/irbrc.example /root/.irbrc

ENV UNICORN_PORT 3000
EXPOSE $UNICORN_PORT

RUN RAILS_ENV=production PUBLIC_SERVICE_URL=foo STAFF_SERVICE_URL=foo SECRET_KEY_BASE=foo bundle exec rake assets:precompile --trace

ENTRYPOINT ["./run.sh"]
