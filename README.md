[![Maintainability](https://api.codeclimate.com/v1/badges/20ad81e6cb95ffd082d2/maintainability)](https://codeclimate.com/github/ministryofjustice/prison-visits-2/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/20ad81e6cb95ffd082d2/test_coverage)](https://codeclimate.com/github/ministryofjustice/prison-visits-2/test_coverage)

# Visit someone in prison

A service for booking a social visit to a prisoner in England or Wales

## Live application

Production application is made available through GOV.UK & can be found at [https://www.gov.uk/prison-visits](https://www.gov.uk/prison-visits)

## Technical Information

This is a Ruby on Rails application that has two main roles. It exposes:

1. A public interface for staff to *manage* prison visit bookings.
2. An API for *booking* prison visits. The consumer of this API is [ministryofjustice/prison-visits-public](https://github.com/ministryofjustice/prison-visits-public).

This is a full rewrite from the ground up, using a database instead of
serialised data in URLs in emails. The CSS and JavaScript has largely been
ported intact from the previous application.

The source of the predecessor can be found at
[ministryofjustice/prison-visits](https://github.com/ministryofjustice/prison-visits).


### Dependencies

- [ministryofjustice/prison-visits-public](https://github.com/ministryofjustice/prison-visits-public) - this a separate Ruby on Rails application that contains the public interface for booking a prison visit.
- [HMPPS Auth](https://github.com/ministryofjustice/hmpps-auth) - for logging into the bookings management interface.
- [Sidekiq](https://sidekiq.org/) - for background processing.
- [Redis](https://redis.io/) - for managing queues (required by Sidekiq)
- [Postgres](https://www.postgresql.org/) - for persisting data
- [Firefox browser v57.0.4](https://download-installer.cdn.mozilla.net/pub/firefox/releases/57.0.4/mac/en-US/Firefox%2057.0.4.dmg)
- [Selenium webdriver](https://www.seleniumhq.org/projects/webdriver/) - for executing tests against different browsers.
- [Geckodriver v0.19.1](https://github.com/mozilla/geckodriver) - for executing tests against the firefox browser.
- [direnv](https://direnv.net/) - for managing environment variables and storing credentials.
- [NOMIS API access](http://ministryofjustice.github.io/nomis-api/) - prison and offender data is accessed via the National Offender Management Information System. An [authentication token](https://nomis-api-access.service.justice.gov.uk/) is required to access this.
- (Optional) Transifex Client - for managing site translation. See [additional documentation](docs/welsh_translation.md) for setup and updating translations.

Emails will be sent to [MailCatcher](http://mailcatcher.me/), if it’s running. See its website for instructions.


### Ruby version

This application uses Ruby v2.6.2. Use [RVM](https://rvm.io/) or similar to manage your ruby environment and sets of dependencies.


### Setup

Install the git pre-commit hook before you start working on this repository so
that we're all using some checks to help us avoid committing unencrypted
secrets. From the root of the repo:

```
ln -s ../../config/git-hooks/pre-commit.sh .git/hooks/pre-commit
```

To test that the pre-commit hook is set up correctly, try removing the `diff`
attribute from a line in a `.gitattributes` file and then committing something -
the hook should prevent you from committing.

### Running the application

*Note* - You will need to spin up both [ministryofjustice/prison-visits-2](https://github.com/ministryofjustice/prison-visits-2) and [ministryofjustice/prison-visits-public](https://github.com/ministryofjustice/prison-visits-public)

1. Install gems (dependencies) locally. To do this you will need to first install [Bundler](http://bundler.io/)

2. Install the `direnv` package
```sh
pvb2 $ brew install direnv

```

3. Create a .env file in the root of the folder and add any necessary environment variables. Load your environment variables into your current session ...
```sh
pvb2 $ direnv allow .

```

4. Install Postgres
```
pvb2 $ brew install postgres

```

5. Install Redis
```sh
pvb2 $ brew install redis

```

6. Install Selenium Webdriver
```sh
pvb2 $ brew install selenium-server-standalone

```

7. Install Geckodriver
```sh
brew install geckodriver

```

8. In separate terminal windows spin up [ministryofjustice/prison-visits-2](https://github.com/ministryofjustice/prison-visits-2) and [Sidekiq](https://sidekiq.org/). The latter processes jobs in the background. Make sure you have the necessary environment variables declared to run Sidekiq. See [additional documentation on queues](docs/queues.md).

```sh
pvb2 $ bundle exec sidekiq
pvb2 $ rails server

```
9. In another terminal window spin up [ministryofjustice/prison-visits-public](https://github.com/ministryofjustice/prison-visits-public) on port 4000

```sh
pvb-public $ rails server -p 4000

```
### Rake tasks

1. Set up database and seed with prison data

```sh
pvb2 $ rake db:setup

```

2. Seed database with visits data

```sh
pvb2 $ rake pvb:populate:visits

```

### Running the test suite

```sh
pvb2 $ rails spec

```

### Further technical information

- [Time Slots using NOMIS (Important!)](docs/nomis_time_slots.md)
- [GovNotify Documentation](docs/gov_notify.md)
- [Processing a request](docs/processing_a_request.md)
- [Notes on models](docs/models.md)
- [Queues](docs/queues.md)
- [Removing outdated personal information](docs/removing_outdated_personal_info.md)
- [Prison data](docs/prison_data.md)
- [Application configuration](docs/configuration.md)
- [Welsh Translation](docs/welsh_translation.md)
- [Frontend](docs/frontend.md)

## Licence

[MIT Licence (MIT)](LICENCE)
