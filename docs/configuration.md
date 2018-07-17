# Configuration

## Development

Emails will be sent to [MailCatcher](http://mailcatcher.me/), if it’s running.
See its website for instructions.

## Environment variables

### `DATABASE_URL`

This will override any settings in `config/database.yml`, and should be of the
form `postgres://myuser:mypass@localhost/somedatabase`.

### `GA_TRACKING_ID`

Google Analytics ID, used for the Performance Platform.

### `MOJSSO_ID, MOJSSO_SECRET, MOJSSO_URL`

Configuration for OAuth based sign-on.

### `NOMIS_API_HOST`

The base URL for the NOMIS API, or API gateway from which the API can be accessed.

(Optional) If not set calls to the NOMIS API will be disabled.

### `NOMIS_API_TOKEN` & `NOMIS_API_KEY`

The `NOMIS_API_KEY` should be set to the client's private key in DER format, encoded as Base64.

The `NOMIS_API_TOKEN` is a JWT token which grants access to the NOMIS API when those requests are signed with the associated `NOMIS_API_KEY`.

(Optional) If not set API calls will be sent without an Authorization header.

### `NOMIS_STAFF_SLOT_AVAILABILITY_ENABLED`

If `true` then the Nomis API will be used to check the slots availability when
staff process a visit.

### `STAFF_PRISONS_WITH_SLOT_AVAILABILITY`

Comma (,) separated list of prisons that have Nomis slot availability enabled
for staff.

Defaults to none by default.

### `NOMIS_STAFF_SLOT_AVAILABILITY_ENABLED`

If `true` then the process visit page will query nomis to check if slots requested
for a visit are available at the requested prison.


### `PUBLIC_PRISONS_WITH_SLOT_AVAILABILITY`

A comma separated list of prisons for which PVB2 API will return slots along with their live availability: check which slots
are available at the requested prison.


### `NOMIS_STAFF_RESTRICTIONS_ENABLED`

If `true` then the process visit page will query the offender restrictions api.

(Optional) By default it is false.

### `STAFF_PRISONS_WITH_RESTRICTIONS_INFO`

A comma separated list of prisons for which the prisoner restrictions is displayed


### `REDIS_URL`

Tells the application where to find a Redis server for use with queues. See
[the redis gem documentation](https://github.com/redis/redis-rb) for more
details.

If not set, the application will attempt to connect to a Redis server on port
6379 of the local host.

### `SECRET_KEY_BASE`

This key is used to verify the integrity of signed cookies. If it is changed,
all old signed cookies will become invalid.

Make sure the secret is at least 30 characters and all random, no regular words
or you’ll be exposed to dictionary attacks. You can use `rake secret` to
generate a secure secret key.

### `PUBLIC_SERVICE_URL`

This is used to build public links in emails. It must be set in the production
environment to `https://prisonvisits.service.gov.uk/`.

### `SSO_REVIEW_BASIC_USER`, `SSO_REVIEW_BASIC_PASSWORD`, `SSO_REVIEW_PARENT_ID`

These are used by the Heroku hooks for review apps to setup and teardown SSO
data.

### `STAFF_SERVICE_URL`

This is used to build staff links in emails. It must be set in the production
environment to `https://staff.prisonvisits.service.gov.uk/`.

### `SESSION_SECRET_KEY`

This is used to sign the session used by the Sidekiq admin interface.

### `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_HOSTNAME`, `SMTP_PORT`, `SMTP_DOMAIN`

These configure email delivery in the production environment. `SMTP_DOMAIN` is
also used when generating the `no-reply@` address and the `feedback@` stand-in
address used when submitting feedback without an email address to Zendesk.

### `STAFF_INFO_ENDPOINT`

This is used to proxy the staff information pages static site.

### `ZENDESK_USERNAME`, `ZENDESK_TOKEN`, `ZENDESK_URL`

These are required in order to submit user feedback to Zendesk.

### `ENABLE_SENDGRID_VALIDATIONS` (optional)

If specified it will enable the email validations that use Sendgrid in the `EmailChecker` class.

### `ASSET_HOST` (optional)

If specified this will configure Rails' `config.asset_host`, resulting in all asset URLs pointing to this host.

### `SENTRY_DSN` (optional)

If specified, exceptions will be sent to the given Sentry project.

### `SENTRY_JS_DSN` (optional)

If specified, Javascript exceptions will be sent to the given Sentry project.

### `PVB_TEAM_EMAIL`

Email address used in the admin mailer.

### Files to be created on deployment

#### `META`

This file, located in the root directory, should be a JSON document containing
build information to be returned by `/ping.json`. e.g.:

```json
{
  "build_date": "2015-12-08T10:18:04.357122",
  "commit_id": "a444e4b05276ae7dc2b1d4224e551dfcbf768795"
}
```
