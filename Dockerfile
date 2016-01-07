FROM ministryofjustice/ruby:2.3.0-webapp-onbuild

ENV UNICORN_PORT 3000
EXPOSE $UNICORN_PORT

RUN chmod +x run.sh
ENTRYPOINT ["./run.sh"]
