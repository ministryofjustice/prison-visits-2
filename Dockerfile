FROM ministryofjustice/ruby:2.3.0-webapp-onbuild

ENV UNICORN_PORT 3000
EXPOSE $UNICORN_PORT

RUN RAILS_ENV=production SERVICE_URL=foo bundle exec rake assets:precompile --trace

ENTRYPOINT ["./run.sh"]
