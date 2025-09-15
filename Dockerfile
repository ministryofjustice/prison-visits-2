FROM ruby:3.3.5-bullseye

ARG BUILD_NUMBER
ARG GIT_BRANCH
ARG GIT_REF

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

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends gnupg curl; \
    install -d -m 0755 /etc/apt/keyrings; \
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
      | gpg --dearmor -o /etc/apt/keyrings/postgresql.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" \
      > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update && \
    apt-get install -y ca-certificates openssl postgresql-client-15 libpq-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./

RUN bundle config set without 'development test'
RUN bundle install --jobs 2 --retry 3

COPY package.json yarn.lock ./

RUN yarn install --prod

COPY . /app

ENV BUILD_NUMBER=${BUILD_NUMBER}
ENV GIT_BRANCH=${GIT_BRANCH}
ENV GIT_REF=${GIT_REF}

RUN mkdir -p /home/appuser && \
  useradd appuser -u 1001 --user-group --home /home/appuser && \
  chown -R appuser:appuser /app && \
  chown -R appuser:appuser /home/appuser

USER 1001

RUN RAILS_ENV=production DISABLE_PROMETHEUS_METRICS=foo PUBLIC_SERVICE_URL=foo STAFF_SERVICE_URL=foo SECRET_KEY_BASE=foo rails assets:precompile --trace

EXPOSE 3000
