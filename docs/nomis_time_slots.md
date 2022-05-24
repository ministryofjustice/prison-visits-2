# Time slots and NOMIS

When trying to spin this system up I noticed that some time slots weren't updating after I updated the yaml files for certain prisons.

**Turns out that some prisons ONLY rely on NOMIS time slots for bookings, so the NOMIS time slots take precedence over the yaml files.**

There are 3 environment variables which dictate if this is enabled and what prisons will only use NOMIS for its time slots

- `NOMIS_STAFF_SLOT_AVAILABILITY_ENABLED` [Link to NOMIS_STAFF_SLOT_AVAILABILITY_ENABLED](https://github.com/ministryofjustice/prison-visits-2/blob/main/docs/configuration.md#nomis_staff_slot_availability_enabled)
- `PUBLIC_PRISONS_WITH_SLOT_AVAILABILITY` [Link to PUBLIC_PRISONS_WITH_SLOT_AVAILABILITY](https://github.com/ministryofjustice/prison-visits-2/blob/main/docs/configuration.md#public_prisons_with_slot_availability)
- `STAFF_PRISONS_WITH_SLOT_AVAILABILITY` [Link to STAFF_PRISONS_WITH_SLOT_AVAILABILITY](https://github.com/ministryofjustice/prison-visits-2/blob/main/docs/configuration.md#staff_prisons_with_slot_availability)

Any prisons listed in `PUBLIC_PRISONS_WITH_SLOT_AVAILABILITY` will only use NOMIS time slots instead of the yaml files.
