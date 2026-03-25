FROM ruby:3.4.8-alpine3.23

ARG BUILD_NUMBER
ARG GIT_BRANCH
ARG GIT_REF

ENV \
  LANG=en_GB.UTF-8 \
  LANGUAGE=en_GB.UTF-8 \
  LC_ALL=en_GB.UTF-8 \
  MUSL_LOCPATH=/usr/share/i18n/locales/musl

WORKDIR /app

RUN \
  set -ex \
  && apk add --no-cache \
    bash \
    build-base \
    ca-certificates \
    curl \
    git \
    libpq \
    musl-locales \
    musl-locales-lang \
    netcat-openbsd \
    nodejs \
    npm \
    openssl \
    postgresql-client \
    postgresql-dev \
    tzdata \
  && cp /usr/share/zoneinfo/Europe/London /etc/localtime \
  && echo "Europe/London" > /etc/timezone \
  && gem update bundler --no-document \
  && npm install -g yarn@1.10.1

RUN \
  set -ex \
  && yarn add govuk-frontend

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
  addgroup -S appuser && \
  adduser -S -u 1001 -G appuser -h /home/appuser appuser && \
  chown -R appuser:appuser /app && \
  chown -R appuser:appuser /home/appuser

USER 1001

RUN RAILS_ENV=production DISABLE_PROMETHEUS_METRICS=foo PUBLIC_SERVICE_URL=foo STAFF_SERVICE_URL=foo SECRET_KEY_BASE=foo rails assets:precompile --trace

EXPOSE 3000
