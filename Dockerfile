FROM ruby:2.4.2-alpine as baseimg
RUN apk add --no-cache ca-certificates git build-base libxml2-dev libxslt-dev postgresql-dev

WORKDIR /usr/src/app
RUN bundle config --global frozen 1 && bundle config --global disable_shared_gems 1 \
  bundle config --global without test:development && bundle config build.nokogiri --use-system-libraries

COPY Gemfile /usr/src/app/Gemfile
COPY Gemfile.lock /usr/src/app/Gemfile.lock
RUN echo "gem: --no-rdoc --no-ri" >> ~/.gemrc && bundle install

# FROM ruby:2.4.2-alpine as testimg
# RUN apk add --no-cache ca-certificates git libxslt-dev libxml2-dev postgresql-dev nodejs
# COPY --from=baseimg /usr/local/bundle /usr/local/bundle
# COPY . /usr/src/app
# WORKDIR /usr/src/app
# RUN bundle exec rake db:create && bundle exec rake db:schema:load
# RUN RAILS_ENV=production PUBLIC_SERVICE_URL=foo STAFF_SERVICE_URL=foo SECRET_KEY_BASE=foo bundle exec rake

FROM ruby:2.4.2-alpine as deployableimg
RUN apk add --no-cache ca-certificates git libxslt-dev libxml2-dev postgresql-dev nodejs
COPY --from=baseimg /usr/local/bundle /usr/local/bundle
COPY . /usr/src/app
WORKDIR /usr/src/app
RUN RAILS_ENV=production PUBLIC_SERVICE_URL=foo STAFF_SERVICE_URL=foo SECRET_KEY_BASE=foo bundle exec rake assets:precompile --trace
ENTRYPOINT ["./run.sh"]
