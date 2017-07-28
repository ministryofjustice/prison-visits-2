# Visit someone in prison

This is a full rewrite from the ground up, using a database instead of
serialised data in URLs in emails. The CSS and JavaScript has largely been
ported intact from the previous application.

The source of the predecessor can be found at
[ministryofjustice/prison-visits](https://github.com/ministryofjustice/prison-visits).

This application exposes an interface to staff to allow managing bookings, and an API which is used by the doubled public facing booking application ([ministryofjustice/prison-visits-public](https://github.com/ministryofjustice/prison-visits-public)).

## Notes on models

### Slots

#### `RecurringSlot`

Represents a time period with begin and end hours and minutes. It does not have
a day or date.

#### `ConcreteSlot`

The expression of a slot on a particular day: this is a unique time that can be
booked.

#### `DayOfWeek`

This is a convenient set of singletons to represent the days of the week as
abstract concepts, separate from a particular date. They are used when
parsing the slot details into recurring and concrete slots.

### Steps

These models are not persisted but have attributes (via Virtus) and validations
to represent each step in the journey of requesting a visit.

#### `PrisonerStep`

The first step: information about the prisoner, including the prison.

#### `VisitorsStep`

The second step: information about the primary visitor and any additional
visitors.

#### `SlotsStep`

The third step: allows selection of slots for the prison.

#### `ConfirmationStep`

This step has only one attribute (`confirmed`) and exists only to facilitate
displaying a confirmation page in the same way as the preceding steps.

### Database tables

#### `Prison`

One record per prison, where a prison is a unique visitable location. That is,
where there are separate booking teams for different wings, those will appear
as distinct records.

Details about slots are stored as a JSON object, with the following structure:

```json
{
  "recurring": {
    "mon": ["1400-1610"],
    "tue": ["0900-1000", "1400-1610"]
  },
  "anomalous": {
    "2014-12-24": ["1400-1600"],
    "2014-12-31": ["1400-1600"]
  },
  "unbookable": ["2014-12-25", "2014-12-26"]
}
```

No slots will be listed for `unbookable` days. For `anomalous` days, the slots
are exactly those given in that section. For all other days, the available
slots are determined by the recurring weekly pattern.

Each prison belongs to an estate.

#### `Estate`

An estate groups prisons that share common characteristics but otherwise handle
booking separately. This might be separate wings with different visiting hours,
or the main and high-security parts of a prison that are handled by different
booking teams.

The estate stores the NOMIS ID and Prison Finder link.

#### `Visit`

This is the main table in the application, and contains the essential data for
a visit: the prison, visit state, and primary visitor’s contact information,
and a reference to a prisoner.

The `processing_state` of a visit is governed by a state machine, with the
following states and transitions:

     .---------.  withdraw  .---------.  reject  .--------.
    ( withdrawn ) <------- ( requested ) -----> ( rejected )
     '---------'            '---------'          '--------'
                                 |
                                 | accept
                                 v
                              .------.          .---------.
                             ( booked ) -----> ( cancelled )
                              '------'  cancel  '---------'

#### `Prisoner`

At present, there is always a one-to-one correspondence between `Prison` and
`Prisoner`. We envisage that in the future a prisoner will have many visits.

`Prisoner` mixes in `Person` for name and age validations and calculations.

#### `Visitor`

These reference a `Visit`. There will always be at least one `Visitor` per
`Visit`: although this is not (and cannot be) enforced at the database level,
visitors are always created from a `VisitorsStep` (which validates this) by
the `BookingRequestCreator`.

`Visitor` mixes in `Person` for name and age validations and calculations.

## Processing a request

The `Prison::VisitsController` is used by prison staff to accept or reject a
visit request. It instantiates a `StaffResponse` object which is responsible
for validating the response. This ensures that a slot or rejection reason is
selected, and that other essential details are present, such as which visitors
are banned when that is the reason for rejection.

When the `StaffResponse` is valid, it is handed to the `BookingResponder`,
which updates the `Visit` record with the new `processing_state` and saves any
other information required.

## Queues

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

This requires the `SESSION_SECRET_KEY` environment variable (see below).

If Redis is running somewhere other than the default port on the local machine,
`REDIS_URL` must be set (see below).

## Removing old personal information

The agreed privacy impact assessment for this service states that personal
details will be purged after one month. To achieve this, a Rake task must be
run at least once a day:

```sh
$ bundle exec rake remove_old_personal_information
```

This will anonymise all personal data in database rows that are more than a
month old by replacing the sensitive fields with `REMOVED` or 1 January in the
year 1 CE.

## Configuration

### Development

Emails will be sent to [MailCatcher](http://mailcatcher.me/), if it’s running.
See its website for instructions.

### Environment variables

#### `DATABASE_URL`

This will override any settings in `config/database.yml`, and should be of the
form `postgres://myuser:mypass@localhost/somedatabase`.

#### `GA_TRACKING_ID`

Google Analytics ID, used for the Performance Platform.

#### `MOJSSO_ID, MOJSSO_SECRET, MOJSSO_URL`

Configuration for OAuth based sign-on.

#### `NOMIS_API_HOST`

The base URL for the NOMIS API, or API gateway from which the API can be accessed.

(Optional) If not set calls to the NOMIS API will be disabled.

#### `NOMIS_API_TOKEN` & `NOMIS_API_KEY`

The `NOMIS_API_KEY` should be set to the client's private key in DER format, encoded as Base64.

The `NOMIS_API_TOKEN` is a JWT token which grants access to the NOMIS API when those requests are signed with the associated `NOMIS_API_KEY`.

(Optional) If not set API calls will be sent without an Authorization header.

#### `NOMIS_STAFF_PRISONER_CHECK_ENABLED`, `NOMIS_PUBLIC_PRISONER_CHECK_ENABLED`

If `true` then the Nomis API will be used for staff or public to check the
prisoner validity.

(Optional) By default it is false.

#### `NOMIS_STAFF_PRISONER_AVAILABILITY_ENABLED`, `NOMIS_PUBLIC_PRISONER_AVAILABILITY_ENABLED`

If `true` then the Nomis API will be used for staff or public to check the
prisoner availability.

(Optional) By default it is false.

#### `NOMIS_STAFF_SLOT_AVAILABILITY_ENABLED`

If `true` then the Nomis API will be used to check the slots availability when
staff process a visit.

#### `STAFF_PRISONS_WITH_SLOT_AVAILABILITY`

Comma (,) separated list of prisons that have Nomis slot availability enabled
for staff.

Defaults to none by default.

#### `STAFF_PRISONS_WITH_SLOT_AVAILABILITY` ####

If `true` then the process visit page will query nomis to check if slots requested
for a visit are available at the requested prison.


#### `STAFF_PRISONS_WITH_SLOT_AVAILABILITY` ####

If `true` then the process visit page will query nomis to check if slots requested
for a visit are available at the requested prison.

#### `PUBLIC_PRISONS_WITH_SLOT_AVAILABILITY` ####

A comma separated list of prisons for which PVB2 API will return slots along with their live availability: check which slots
are available at the requested prison.

#### `STAFF_PRISONS_WITH_NOMIS_CONTACT_LIST` ####

A comma separated list of prisons for which PVB2 API will display the nomis
contact list on the process visit page.

#### `NOMIS_STAFF_OFFENDER_RESTRICTIONS_ENABLED`

If `true` then the process visit page will query the offender restrictions api.

(Optional) By default it is false.

#### `NOMIS_STAFF_BOOK_TO_NOMIS_ENABLED`

If `true` then the Nomis API will be used to book a visit.

### `STAFF_PRISONS_WITH_BOOK_TO_NOMIS` ###

A comma separated list of prisons for which the book to nomis API is enabled

#### `PRISON_ESTATE_IPS` ####

A semicolon- or comma-separated list of IP addresses or CIDR ranges. Users on
these addresses can access the prison booking admin pages.

#### `REDIS_URL` ####

Tells the application where to find a Redis server for use with queues. See
[the redis gem documentation](https://github.com/redis/redis-rb) for more
details.

If not set, the application will attempt to connect to a Redis server on port
6379 of the local host.

#### `SECRET_KEY_BASE` ####

This key is used to verify the integrity of signed cookies. If it is changed,
all old signed cookies will become invalid.

Make sure the secret is at least 30 characters and all random, no regular words
or you’ll be exposed to dictionary attacks. You can use `rake secret` to
generate a secure secret key.

#### `PUBLIC_SERVICE_URL` ####

This is used to build public links in emails. It must be set in the production
environment to `https://prisonvisits.service.gov.uk/`.

#### `SSO_REVIEW_BASIC_USER`, `SSO_REVIEW_BASIC_PASSWORD`, `SSO_REVIEW_PARENT_ID` ####

These are used by the Heroku hooks for review apps to setup and teardown SSO
data.

#### `STAFF_SERVICE_URL` ####

This is used to build staff links in emails. It must be set in the production
environment to `https://staff.prisonvisits.service.gov.uk/`.

#### `SESSION_SECRET_KEY` ####

This is used to sign the session used by the Sidekiq admin interface.

#### `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_HOSTNAME`, `SMTP_PORT`, `SMTP_DOMAIN` ####

These configure email delivery in the production environment. `SMTP_DOMAIN` is
also used when generating the `no-reply@` address and the `feedback@` stand-in
address used when submitting feedback without an email address to Zendesk.

#### `STAFF_INFO_ENDPOINT` ####

This is used to proxy the staff information pages static site.

#### `ZENDESK_USERNAME`, `ZENDESK_TOKEN`, `ZENDESK_URL` ####

These are required in order to submit user feedback to Zendesk.

`ZENDESK_URL` defaults to `https://ministryofjustice.zendesk.com/api/v2`.

#### `ENABLE_SENDGRID_VALIDATIONS` (optional) ####

If specified it will enable the email validations that use Sendgrid in the `EmailChecker` class.

#### `ASSET_HOST` (optional) ####

If specified this will configure Rails' `config.asset_host`, resulting in all asset URLs pointing to this host.

#### `SENTRY_DSN` (optional) ####

If specified, exceptions will be sent to the given Sentry project.

#### `SENTRY_JS_DSN` (optional)

If specified, Javascript exceptions will be sent to the given Sentry project.

#### `PVB_TEAM_EMAIL` ####

Email address used in the admin mailer.

#### Files to be created on deployment ####

##### `META` #####

This file, located in the root directory, should be a JSON document containing
build information to be returned by `/ping.json`. e.g.:

```json
{
  "build_date": "2015-12-08T10:18:04.357122",
  "commit_id": "a444e4b05276ae7dc2b1d4224e551dfcbf768795"
}
```

## Prison data

Prison details are stored in YAML files in the `db/seeds` directory, and are
synchronised to the database on deployment (by running `rake db:seed`). This is
an idempotent operation: running `rake db:seed` multiple times will have the
same effect as running it once.

The files can be edited by anyone with access to this repository. The
[YAML](http://en.wikipedia.org/wiki/YAML) specification is complex and fraught
with edge cases, so be careful.

For the purposes of this application, a **prison** is a visitable location
within an **estate**. There will be more than one prison if different parts of
the estate have different visiting times or booking teams.

Estates are seeded via the `estates.yml` file.

### Estates

`estates.yml` is formatted thus:

```yaml
LNX: # NOMIS ID
  name: Lunar Penal Colony
  finder_slug: moonbase
MRX:
  name: Martian Correctional Facility
```

An estate can be added by adding a new entry to the file. The name or finder
slug can be changed as long as the NOMIS ID remains the same.

It is not possible to delete an estate: removing it from the seed data will not
remove it from the database.

#### Prison finder links

When the service links to [Prison
Finder](https://www.justice.gov.uk/contacts/prison-finder), it turns the estate
name into part of the URL. For example, ‘Drake Hall’ becomes
[drake-hall](https://www.justice.gov.uk/contacts/prison-finder/drake-hall).

When the Prison Finder link does not simply match the estate name in lower
case with spaces replaced with hyphens, use the `finder_slug` field:

```yaml
finder_slug: sheppey-cluster-standford-hill
```

### Prisons

#### Prison visibility

All known prisons should exist in the data files. If a prison is not in scope
of the service, it should be disabled.

To disable visit requests to a prison, set `enabled` to `false`.

```yaml
  nomis_id: SFI
  enabled: false # this prison does not accept online visit request through this service
  name: Stafford
  ...

```

Each prison **must** have a `nomis_id` field that corresponds to an entry in
`estates.yml`.

#### Recurring weekly visiting slots

Slots are defined per prison via a weekly schedule. Only days listed here with
a list of slots will appear on the slot picker.

Use 3 letter strings for days of the week. Times are entered in the 24 hour
format.

```yaml
recurring:
  wed:
  - 1350-1450 # creates a 1 hour slot every Wednesday from 1:50pm
  sat:
  - 0900-1100 # creates a 2 hour slot every Saturday from 9am
  - 1330-1530 # creates a 2 hour slot every Saturday from 1:30pm
```

#### Slot anomalies

Use this to make exceptions to the weekly schedule.

When a day is found in `anomalous` the whole day is replaced with this
data. Therefore if the weekday usually contains multiple slots and only a
single slot is to be edited, the rest of the slots need to be re-entered.

```yaml
anomalous:
  2015-01-10:
  - 0930-1130 # replaces Saturday 10 January 2015 with only one slot at 9:30am
```

#### Non-bookable days

Use this to remove specified dates, such as staff training days or Christmas
Day from the schedule. Public holidays are already excluded by default:
visiting can be enabled by adding them as anomalies, above.

This overrides `slots`.

```yaml
unbookable:
- 2015-12-25 # removes any slots from 25 December 2015
```

**Note** If an enabled prison does not have any unbookable dates, please
make sure you represent this in the yaml as:

```yaml
unbookable: []
```

If you do not, the specs will fail.

#### Response times

Set the amount of full working days which booking staff have to respond to each
request. The default is 3 days.

For example, on a Monday, requests can be made for Friday. Set this value to
`2` and it will be possible to make requests for Thursday.

```yaml
lead_days: 2 # two full working days after current day
```

#### Weekend processing

Use this when a prison has booking staff who can respond to requests over
weekends. This will allow visits to be requested 3 days ahead (or custom
`lead_day`) regardless of whether they are weekdays.

```yaml
works_weekends: true
```

#### Adult age

Visit requests must have a minimum of one and a maximum of 3 "adults" (18 years
old and over, by default). The adult age can be reduced to restrict the amount
of visitors over that age.

**Note** visiting areas have 3 seats for visitors and one for the prisoner.
Children are expect to sit on the laps of adults.

```yaml
adult_age: 15 # allow only 3 visitors over the age of 15
```

#### Translating prison names and addresses

You can override the name and address for a given language. In practice, as the
majority of prisons are in England, this is a mechanism for adding Welsh
translations. This is achieved by adding the translated name and/or address
to the `translations` field under the language identifier – this is `en` for
English and `cy` for Welsh (from ‘Cymraeg’).

```yaml
name: Swansea
address: |-
  200 Oystermouth Road
  Swansea
  SA1 3SR
translations:
  cy:
    name: Abertawe
    address: |-
      200 Heol Oystermouth
      Abertawe
      SA1 3SR
```

#### Adding a prison

Prisons are identified by the filename-to-UUID mappings in
`db/seeds/prison_uuid_mappings.yml`. (A UUID is a long, unique identifier that
looks like `85c83a07-dd6a-43ea-ae41-af79e4a756d4`.)

To add a prison, create a new YAML file in `db/seeds/prisons` and add a line to
the mapping file. To generate a new UUID for the prison, you can type `uuidgen`
on the command line in Linux or OS X, or use a rake task:

```sh
$ rake maintenance:prison_uuids
```

#### Renaming a prison

The minimum necessary is to change the `name` field in the prison YAML file. If
you want to change the file name, this must be updated in the mappings. Do not
change the UUID.

#### Deleting a prison

You can’t. This is because historical bookings still refer to that prison.
Disable it instead (see above).

#### Merging two prisons

If two formerly-separate parts of an estate now have the same booking team and
visiting times, they can be combined into one so that visitors only have one
relevant choice in the prison selection interface.

This is the appropriate process:

1. Disable the individual prisons (by setting `enabled: false`)
2. Add a new prison (see above) with the same estate


#### Splitting a prison

Conversely, if different parts of an estate now have distinct booking teams or
visiting times, they can be separated:

1. Disable the prison
2. Add two or more prisons with the same estate.

## Welsh translation

NOMS Wales manages translations via Transifex. This means that we:

* Write English translations in the YAML files as usual.
* Push the English up to Transifex.
* Pull down Welsh from Transifex.

In order to use Transifex, you need the client and an account.

The Transifex client is written in Python and can be installed via

```sh
$ pip install transifex-client
```

You will also need to [configure the user account for the
client](http://docs.transifex.com/client/config/#transifexrc).

To push the English translations to Transifex, use

```sh
tx push -s
```

To pull Welsh, use

```sh
tx pull -l cy
```

Then commit as usual.
