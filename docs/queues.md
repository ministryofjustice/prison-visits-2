# Queues

In the development and production environments, queues are backed by Redis via
Sidekiq. To run the consumers:

```
$ bundle exec sidekiq
```

**NOTE**: The queue consumers **must** be restarted when the application is
updated.

An interface to the queues is available by running the Sidekiq web interface:

```sh
$ bundle exec rackup sidekiq-admin.ru
```

This requires the `SESSION_SECRET_KEY` environment variable (see [configuration notes](docs/configuration.md)).

If Redis is running somewhere other than the default port on the local machine,
`REDIS_URL` must be set (see below).
