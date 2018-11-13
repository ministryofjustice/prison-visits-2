# Notes on models

## Slots

### `RecurringSlot`

Represents a time period which begins and ends in hours and minutes. It does not have
a day or date.

### `ConcreteSlot`

The expression of a slot on a particular day: this is a unique time that can be
booked.

### `DayOfWeek`

This is a convenient set of singletons to represent the days of the week as
abstract concepts, separate from a particular date. They are used when
parsing the slot details into recurring and concrete slots.

### Steps

(This steps is a legacy from when PVB Public was all in one application. Ideally
these would be refactored so that the API would use services to validate and
persist the data)

These models are not persisted but have attributes (via ActiveModel) and validations
to represent each step in the journey of requesting a visit.

### `PrisonerStep`

The first step: information about the prisoner, including the prison.

### `VisitorsStep`

The second step: information about the primary visitor and any additional
visitors.

### `SlotsStep`

The third step: allows selection of slots for the prison.


## Database tables

### `Prison`

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

### `Estate`

An estate groups prisons that share common characteristics but otherwise handle
booking separately. This might be separate wings with different visiting hours,
or the main and high-security parts of a prison that are handled by different
booking teams.

The estate stores the NOMIS ID and Prison Finder link.

### `Visit`

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

### `Prisoner`

At present, there is always a one-to-one correspondence between `Prison` and
`Prisoner`. We envisage that in the future a prisoner will have many visits.

`Prisoner` mixes in `Person` for name and age validations and calculations.

### `Visitor`

These reference a `Visit`. There will always be at least one `Visitor` per
`Visit`: although this is not (and cannot be) enforced at the database level,
visitors are always created from a `VisitorsStep` (which validates this) by
the `BookingRequestCreator`.

`Visitor` mixes in `Person` for name and age validations and calculations.
