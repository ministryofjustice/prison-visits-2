[![Maintainability](https://api.codeclimate.com/v1/badges/20ad81e6cb95ffd082d2/maintainability)](https://codeclimate.com/github/ministryofjustice/prison-visits-2/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/20ad81e6cb95ffd082d2/test_coverage)](https://codeclimate.com/github/ministryofjustice/prison-visits-2/test_coverage)

# Visit someone in prison

A service for booking a social visit to a prisoner in England or Wales

## Live application

Production application is made available through GOV.UK and can be found at [https://www.gov.uk/prison-visits](https://www.gov.uk/prison-visits) 

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
- [Sidekiq](https://sidekiq.org/) - for background processing.
- [Redis](https://redis.io/) - for managing queues (required by Sidekiq)
- [Postgres](https://www.postgresql.org/) - for persisting data
- [Selenium webdriver](https://www.seleniumhq.org/projects/webdriver/) - for executing tests against different browsers.
- [Geckodriver](https://github.com/mozilla/geckodriver) - for executing tests against the firefox browser.
- [direnv](https://direnv.net/) - for managing environment variables and storing credentials.
- [NOMIS API access](http://ministryofjustice.github.io/nomis-api/) - prison and offender data is accessed via the National Offender Management Information System. An [authentication token](https://nomis-api-access.service.justice.gov.uk/) is required to access this.
- (Optional) Transifex Client - for managing site translation. See [additional documentation](docs/welsh_translation.md) for setup and updating translations.       


### Ruby version

This application uses Ruby v2.4.2. Use [RVM](https://rvm.io/) or similar to manage your ruby environment and sets of dependencies. 


### Running the application

*Note* - You will need to spin up both [ministryofjustice/prison-visits-2](https://github.com/ministryofjustice/prison-visits-2) and [ministryofjustice/prison-visits-public](https://github.com/ministryofjustice/prison-visits-public)

1. Install gems (dependencies) locally. To do this you will need to first install [Bundler](http://bundler.io/)
2. Install the *direnv* package
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

4. Install Redis
```sh
pvb2 $ brew install redis

```

5. Install Selenium Webdriver
```sh
pvb2 $ brew install selenium-server-standalone

```

6. Install Geckodriver
```sh
brew install geckodriver

```

7. In separate terminal windows spin up [ministryofjustice/prison-visits-2](https://github.com/ministryofjustice/prison-visits-2) and [Sidekiq](https://sidekiq.org/). The latter processes jobs in the background. Make sure you have the necessary environment variables declared to run Sidekiq. See [additional documentation on queues](docs/queues.md).

```sh
pvb2 $ bundle exec sidekiq
pvb2 $ rails server

```
8. In another terminal window spin up [ministryofjustice/prison-visits-public](https://github.com/ministryofjustice/prison-visits-public) on port 4000

```sh
pvb-public $ rails server -p 4000

```

### Running the test suite

```sh
pvb2 $ rails spec

```    

### Further technical information

  - [Processing a request](docs/processing_a_request.md)
  - [Notes on models](docs/models.md)
  - [Queues](docs/queues.md)
  - [Removing outdated personal information](docs/removing_outdated_personal_info.md)
  - [Prison data](docs/prison_data.md)
  - [Application configuration](docs/configuration.md)
- [Welsh Translation](docs/welsh_translation.md)


### Licence

