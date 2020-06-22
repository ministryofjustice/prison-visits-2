# Removing old personal information

The agreed privacy impact assessment for this service states that personal
details older than six months will be anonymised. To achieve this, a Rake task must be
run at least once a day:

```sh
$ bundle exec rake remove_old_personal_information
```

This will anonymise all personal data in database rows that are more than a
month old by replacing the sensitive fields with `REMOVED` or 1 January in the
year 1 CE.
