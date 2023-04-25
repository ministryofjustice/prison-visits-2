FROM ruby:2.6.7-stretch

RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list

RUN \
  set -ex \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install \
    -y \
    --no-install-recommends \
    locales \
  && sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen \
  && dpkg-reconfigure --frontend=noninteractive locales \
  && update-locale LANG=en_GB.UTF-8

ENV \
  LANG=en_GB.UTF-8 \
  LANGUAGE=en_GB.UTF-8 \
  LC_ALL=en_GB.UTF-8

WORKDIR /app

RUN \
  set -ex \
  && apt-get install \
    -y \
    --no-install-recommends \
    apt-transport-https \
    build-essential \
    libpq-dev \
    netcat \
    nodejs \
  && timedatectl set-timezone Europe/London || true \
  && gem update bundler --no-document

RUN \
  set -ex \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN \
  set -ex \
  && apt-get update \
  && apt-get install \
    -y \
    --no-install-recommends \
    yarn=1.10.1-1 \
  && yarn add govuk-frontend


RUN echo "deb http://apt-archive.postgresql.org/pub/repos/apt/ stretch-pgdg main" >  /etc/apt/sources.list.d/pgdg.list && \
    wget --no-check-certificate -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# Update openssl & ca-certificates so that communication with signon can take place
# (TODO: Remove this when base container has been updated)
RUN apt-get update && \
    apt-get install -y ca-certificates openssl postgresql-client-12 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./

RUN bundle install --without development test --jobs 2 --retry 3

COPY . /app

RUN mkdir -p /home/appuser && \
  useradd appuser -u 1001 --user-group --home /home/appuser && \
  chown -R appuser:appuser /app && \
  chown -R appuser:appuser /home/appuser

USER 1001

RUN RAILS_ENV=production DISABLE_PROMETHEUS_METRICS=foo PUBLIC_SERVICE_URL=foo STAFF_SERVICE_URL=foo SECRET_KEY_BASE=foo rails assets:precompile --trace

EXPOSE 3000
