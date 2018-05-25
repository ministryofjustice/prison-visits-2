# Prison data

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

## Estates

`estates.yml` is formatted thus:

```yaml
LNX: # NOMIS ID
  name: Lunar Penal Colony
  finder_slug: moonbase
  admins:
    - lunar.prisons.nomis.moj
MRX:
  name: Martian Correctional Facility
  admins:
    - martian.prisons.nomis.moj
    - starfleet.nomis.moj
```

An estate can be added by adding a new entry to the file. The name or finder
slug can be changed as long as the NOMIS ID remains the same. The admins array
specifies which groups are allowed to manage the visits booking for that estate.
Often prisons will manage their own bookings but there are cases where this is
outsourced or responsibility is shared.

It is not possible to delete an estate: removing it from the seed data will not
remove it from the database.

### Prison finder links

When the service links to [Prison
Finder](https://www.justice.gov.uk/contacts/prison-finder), it turns the estate
name into part of the URL. For example, ‘Drake Hall’ becomes
[drake-hall](https://www.justice.gov.uk/contacts/prison-finder/drake-hall).

When the Prison Finder link does not simply match the estate name in lower
case with spaces replaced with hyphens, use the `finder_slug` field:

```yaml
finder_slug: sheppey-cluster-standford-hill
```

## Prisons

### Prison visibility

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

### Recurring weekly visiting slots

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

### Slot anomalies

Use this to make exceptions to the weekly schedule.

When a day is found in `anomalous` the whole day is replaced with this
data. Therefore if the weekday usually contains multiple slots and only a
single slot is to be edited, the rest of the slots need to be re-entered.

```yaml
anomalous:
  2015-01-10:
  - 0930-1130 # replaces Saturday 10 January 2015 with only one slot at 9:30am
```

### Non-bookable days

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

### Response times

Set the amount of full working days which booking staff have to respond to each
request. The default is 3 days.

For example, on a Monday, requests can be made for Friday. Set this value to
`2` and it will be possible to make requests for Thursday.

```yaml
lead_days: 2 # two full working days after current day
```

### Weekend processing

Use this when a prison has booking staff who can respond to requests over
weekends. This will allow visits to be requested 3 days ahead (or custom
`lead_day`) regardless of whether they are weekdays.

```yaml
works_weekends: true
```

### Adult age

Visit requests must have a minimum of one and a maximum of 3 "adults" (18 years
old and over, by default). The adult age can be reduced to restrict the amount
of visitors over that age.

**Note** visiting areas have 3 seats for visitors and one for the prisoner.
Children are expect to sit on the laps of adults.

```yaml
adult_age: 15 # allow only 3 visitors over the age of 15
```

### Translating prison names and addresses

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

### Adding a prison

Prisons are identified by the filename-to-UUID mappings in
`db/seeds/prison_uuid_mappings.yml`. (A UUID is a long, unique identifier that
looks like `85c83a07-dd6a-43ea-ae41-af79e4a756d4`.)

To add a prison, create a new YAML file in `db/seeds/prisons` and add a line to
the mapping file. To generate a new UUID for the prison, you can type `uuidgen`
on the command line in Linux or OS X, or use a rake task:

```sh
$ rake maintenance:prison_uuids
```

### Renaming a prison

The minimum necessary is to change the `name` field in the prison YAML file. If
you want to change the file name, this must be updated in the mappings. Do not
change the UUID.

### Deleting a prison

You can’t. This is because historical bookings still refer to that prison.
Disable it instead (see above).

### Merging two prisons

If two formerly-separate parts of an estate now have the same booking team and
visiting times, they can be combined into one so that visitors only have one
relevant choice in the prison selection interface.

This is the appropriate process:

1. Disable the individual prisons (by setting `enabled: false`)
2. Add a new prison (see above) with the same estate


### Splitting a prison

Conversely, if different parts of an estate now have distinct booking teams or
visiting times, they can be separated:

1. Disable the prison
2. Add two or more prisons with the same estate.
