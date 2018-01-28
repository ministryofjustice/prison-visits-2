FROM ruby:2.4.2-alpine as baseimg
# Install all build dependencies
RUN apk add --no-cache ca-certificates git build-base libxml2-dev libxslt-dev postgresql-dev

WORKDIR /usr/src/app
RUN bundle config --global frozen 1 && bundle config --global disable_shared_gems 1 \
  bundle config --global without test:development && bundle config build.nokogiri --use-system-libraries

COPY Gemfile /usr/src/app/Gemfile
COPY Gemfile.lock /usr/src/app/Gemfile.lock
RUN echo "gem: --no-rdoc --no-ri" >> ~/.gemrc && bundle install


# Collect gems built in previous step
FROM ruby:2.4.2-alpine as deployableimg
RUN apk add --no-cache ca-certificates git libxslt-dev libxml2-dev postgresql-dev nodejs
COPY --from=baseimg /usr/local/bundle /usr/local/bundle
COPY . /usr/src/app
# COPY --from=baseimg /usr/src/app/.bundle /usr/src/app/
WORKDIR /usr/src/app
RUN RAILS_ENV=production PUBLIC_SERVICE_URL=foo STAFF_SERVICE_URL=foo SECRET_KEY_BASE=foo bundle exec rake assets:precompile --trace
ENTRYPOINT ["./run.sh"]


# Update openssl & ca-certificates so that communication with signon can take place
# (TODO: Remove this when base container has been updated)


# FROM ruby:alpine as project
# RUN apk add --no-cache ca-certificates



# RUN apt-get update && \
#     apt-get install -y ca-certificates openssl postgresql-client-9.4 && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/*

# ENV UNICORN_PORT 3000
# EXPOSE $UNICORN_PORT

# RUN gem update bundler --no-doc

# RUN RAILS_ENV=production PUBLIC_SERVICE_URL=foo STAFF_SERVICE_URL=foo SECRET_KEY_BASE=foo bundle exec rake assets:precompile --trace

# ENTRYPOINT ["./run.sh"]
