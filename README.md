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

## The visit request process

The `StepsController` has only two actions, `index` and `create`, which means
only one path, differentiated by `GET` or `POST`. It is completely stateless:
progression through the steps is determined by the availability of complete
information in the preceding steps, passed either as user-completed form fields
or (in the case of preceding steps) as hidden fields.

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

## Configuration

### Development

Emails will be sent to [MailCatcher](http://mailcatcher.me/), if it's running.
See its website for instructions.

## Environment variables used by the application

### DATABASE_URL

This will override any settings in `config/database.yml`, and should be of the
form `postgres://myuser:mypass@localhost/somedatabase`.

### GOVUK_START_PAGE

Visiting `/` will redirect to this URL, if supplied, or the new booking page
otherwise. On production, this must be set to
[https://www.gov.uk/prison-visits](https://www.gov.uk/prison-visits), the
official start page for the service.

### SECRET_KEY_BASE

This key is used to verify the integrity of signed cookies. If it is changed,
all old signed cookies will become invalid.

Make sure the secret is at least 30 characters and all random, no regular words
or you'll be exposed to dictionary attacks. You can use `rake secret` to
generate a secure secret key.

### SERVICE_URL

This is used to build links in emails. It must be set in the production
environment to `https://www.prisonvisits.service.gov.uk/`.

### SMTP_USERNAME, SMTP_PASSWORD, SMTP_HOSTNAME, SMTP_PORT, SMTP_DOMAIN

These configure email delivery in the production environment.
