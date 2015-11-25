# Visit someone in prison

This is a spike on a full rewrite from the ground up, using a database instead
of serialised data in URLs in emails.

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

#### `Visit`

This is the main table in the application, and contains the essential data for
a visit: the prison, visit state, and primary visitor's contact information,
and a reference to a prisoner.

The `processing_state` of a visit is governed by a state machine, with the
following states and transitions:

     .---------.  withdraw  .---------.  reject  .--------.
    ( withdrawn ) <------- ( requested ) -----> ( rejected )
     '---------'            '---------'          '--------'
                                 |
                                 | accept
                                 v
                              .------.          .--------.
                             ( booked ) -----> ( cancelled )
                              '------'  cancel  '--------'

#### `Prisoner`

At present, there is always a one-to-one correspondance between `Prison` and
`Prisoner`. We envisage that in the future a prisoner will have many visits.

`Prisoner` mixes in `Person` for name and age validations and calculations.

#### `Visitor`

These reference a `Visit`. There will always be at least one `Visitor` per
`Visit`: although this is not (and cannot be) enforced at the database level,
visitors are always created from a `VisitorsStep` (which validates this) by
the `BookingRequestCreator`.

`Visitor` mixes in `Person` for name and age validations and calculations.

## Requesting a visit

The `BookingRequestsController` has only two actions, `index` and `create`,
which means only one path, differentiated by `GET` or `POST`. It is completely
stateless: progression through the steps is determined by the availability of
complete information in the preceding steps, passed either as user-completed
form fields or (in the case of preceding steps) as hidden fields.

The logic of processing steps and determining which step has been reached is
handled by the `StepsProcessor` class.

On an initial `GET`, the first step (`PrisonerStep`) is instantiated with no
parameters.

Thereafter, on a `POST` request, each step in turn is instantiated using the
named parameters for that step (if available). The first incomplete step (where
incompleteness is determined by the complete absence of parameters for that
step, or by the invalidity of those supplied) determines the template to be
rendered.

Finally, if all steps are complete, a `Visit` is created by
`BookingRequestCreator` and the `completed` template is rendered.

## Processing a request

The `Prison::VisitsController` is used by prison staff to accept or reject a
visit request. It instantiates a `BookingResponse` object which is responsible
for validating the response. This ensures that a slot or rejection reason is
selected, and that other essential details are present, such as which visitors
are banned when that is the reason for rejection.

When the `BookingResponse` is valid, it is handed to the `BookingResponder`,
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

Emails will be sent to [MailCatcher](http://mailcatcher.me/), if it's running.
See its website for instructions.

### Environment variables

#### `DATABASE_URL`

This will override any settings in `config/database.yml`, and should be of the
form `postgres://myuser:mypass@localhost/somedatabase`.

#### `GOVUK_START_PAGE`

Visiting `/` will redirect to this URL, if supplied, or the new booking page
otherwise. On production, this must be set to
[https://www.gov.uk/prison-visits](https://www.gov.uk/prison-visits), the
official start page for the service.

#### `PRISON_ESTATE_IPS`

A semicolon- or comma-separated list of IP addresses or CIDR ranges. Users on
these addresses can access the prison booking admin pages.

#### `SECRET_KEY_BASE`

This key is used to verify the integrity of signed cookies. If it is changed,
all old signed cookies will become invalid.

Make sure the secret is at least 30 characters and all random, no regular words
or you'll be exposed to dictionary attacks. You can use `rake secret` to
generate a secure secret key.

#### `SERVICE_URL`

This is used to build links in emails. It must be set in the production
environment to `https://www.prisonvisits.service.gov.uk/`.

#### `SESSION_SECRET_KEY`

This is used to sign the session used by the Sidekiq admin interface.

#### `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_HOSTNAME`, `SMTP_PORT`, `SMTP_DOMAIN`

These configure email delivery in the production environment. `SMTP_DOMAIN` is
also used when generating the `no-reply@` address and the `feedback@` stand-in
address used when submitting feedback without an email address to Zendesk.

#### `ZENDESK_USERNAME`, `ZENDESK_TOKEN`, `ZENDESK_URL`

These are required in order to submit user feedback to Zendesk.

`ZENDESK_URL` defaults to `https://ministryofjustice.zendesk.com/api/v2`.

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

### Prisons

#### Editing prison data

Prison details are stored in YAML files in the `db/seeds` directory, and are
synchronised to the database on deployment (by running `rake db:seed`). This is
an idempotent operation: running `rake db:seed` multiple times will have the
same effect as running it once.

The files can be edited by anyone with access to this repository. The
[YAML](http://en.wikipedia.org/wiki/YAML) specification is complex and fraught
`SMOKE_TEST_EMAIL_LOCAL_PART`@`SMOKE_TEST_EMAIL_DOMAIN`, it will not
send that email to the prison, but will direct all mail the
with edge cases, so be careful.

#### Prison visibility
To start the smoke tests, set the environment variables and run
`ruby ./smoke_test/smoke_test.rb`.

All known prisons should exist in the data files. If a prison is not in scope
of the service, it should be disabled.

##### Smoke Test Steps:
  1. Starts the form
  2. Fills in prisoner details page
  3. Fills in visitor details page for one visitor
  4. Selects three available days on the slot page
  5. Submits the booking on the check your request page
  6. Checks that the user received a booking receipt email
  7. Checks that the prison received a booking request email
  8. Visits the process booking page and confirms the booking
To disable visit requests to a prison, set `enabled` to `false`.
  10. Checks that the visitor received a confirmation email
  11. Checks the status of the visit and cancels it
  12. Checks that the prison receives a booking cancellation email

```yaml
  nomis_id: SFI
  enabled: false # this prison does not accept online visit request through this service
  name: Stafford
  ...

```
SMOKE_TEST_EMAIL_LOCAL_PART
#### Weekly visiting slots

Slots are defined per prison via a weekly schedule. Only days listed here with
a list of slots will appear on the slot picker.

Use 3 letter strings for days of the week. Times are entered in the 24 hour
format.

```yaml
slots:
  wed:
  - 1350-1450 # creates a 1 hour slot every Wednesday from 1:50pm
  sat:
  - 0900-1100 # creates a 2 hour slot every Saturday from 9am
SMOKE_TEST_EMAIL_DOMAIN
```

#### Slot anomalies

##### Required environment variables for the smoke test:

When a day is found in `slot_anomalies` the whole day is replaced with this
data. Therefore if the weekday usually contains multiple slots and only a
single slot is to be edited, the rest of the slots need to be re-entered.

```yaml
slot_anomalies:
  2015-01-10:
  - 0930-1130 # replaces Saturday 10 January 2015 with only one slot at 9:30am
```
SMOKE_TEST_EMAIL_LOCAL_PART
SMOKE_TEST_EMAIL_DOMAIN
SMOKE_TEST_EMAIL_PASSWORD
SMOKE_TEST_APP_HOST
Day from the schedule. Public holidays are already excluded by default:
visiting can be enabled by adding them as anomalies, above.

This overrides `slots`.

```yaml
unbookable:
SMOKE_TEST_EMAIL_HOST
```
### `SMOKE_TEST_EMAIL_LOCAL_PART`, `SMOKE_TEST_EMAIL_DOMAIN`

These determine the email address that will trigger the smoke tests on
the application. See note above.

```yaml
unbookable: []
### `SMOKE_TEST_EMAIL_HOST`, `SMOKE_TEST_EMAIL_PASSWORD`

These are the details for the IMAP host that allows the smoke test to
check that the emails have been delivered.

### `SMOKE_TEST_APP_HOST`

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

#### Prison finder links

When the service links to [Prison
Finder](https://www.justice.gov.uk/contacts/prison-finder), it turns the prison
This is the url of the particular version of the application that the
[drake-hall](https://www.justice.gov.uk/contacts/prison-finder/drake-hall).

When the Prison Finder link does not simply match the prison name in lower
case with spaces replaced with hyphens, use this.

```yaml
finder_slug: sheppey-cluster-standford-hill
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

#### Adding a prison

Prisons are identified by the filename-to-UUID mappings in
`db/seeds/prison_uuid_mappings.yml`. (A UUID is a long, unique identifier that
looks like `85c83a07-dd6a-43ea-ae41-af79e4a756d4`.)

To add a prison, create a new YAML file in `db/seeds/prisons` and add a line to
the mapping file. To generate a new UUID for the prison, you can type `uuidgen`
on the command line in Linux or OS X.

#### Renaming a prison

The minimum necessary is to change the `name` field in the prison YAML file. If
you want to change the file name, this must be updated in the mappings. Do not
change the UUID.

#### Deleting a prison

You can't. This is because historical bookings still refer to that prison.
smoke test will run against.
