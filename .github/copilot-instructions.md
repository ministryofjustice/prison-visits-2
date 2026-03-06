# Copilot instructions for prison-visits-2

## Big picture
- This Rails app exposes two surfaces: a staff UI and a JSON API consumed by `prison-visits-public` (see `config/routes.rb`).
- Staff processing flow is `prison/dashboards` -> `prison/visits` -> `BookingResponder` strategies (`app/services/booking_responder/*`).
- API booking flow is `Api::VisitsController#create` -> `PrisonerStep`/`VisitorsStep`/`SlotsStep` -> `BookingRequestCreator#create!`.
- The core lifecycle is `Visit` state machine transitions (`requested`, `booked`, `rejected`, `cancelled`, `withdrawn`) in `app/models/visit.rb`.
- Every state transition appends a `VisitStateChange` record; preserve this audit trail behavior when changing booking logic.
- Estate scoping is security-critical: staff visit access is filtered via `StaffResponseContext#scoped_visit`.

## Request/response patterns
- Keep controllers thin and move business logic into service objects (`app/services/**`) and memory-model steps (`app/models/*_step.rb`).
- API controllers should inherit `Api::ApiController` for JSON enforcement, deadline handling, and standardized `ParameterError` responses.
- Preserve API contracts via Jbuilder templates under `app/views/api/**` (for example `app/views/api/visits/show.json.jbuilder`).
- Staff views use decorators/presenters (`app/decorators`, `app/presenters`) for UI/domain formatting; avoid pushing view logic into controllers.

## Integration boundaries
- Use `Nomis::Api`/`Nomis::Client` (`app/services/nomis`) for prison/prisoner data; do not add direct Excon calls in controllers/models.
- NOMIS calls are instrumented and carry request metadata (`RequestStore` deadline/request_id) via `config/initializers/pvb_instrumentation.rb`.
- Staff auth uses custom HMPPS SSO OmniAuth strategy (`lib/hmpps_sso.rb`) and estate mapping in `SignonIdentity`.
- Visitor/staff notifications are centralized in `GovNotifyEmailer`; booking responder classes trigger template sends.
- Feedback-to-Zendesk handoff is asynchronous via `ZendeskTicketsJob`.
- Google Analytics side effects are isolated in `GATracker` and invoked from prison visit controllers after process/cancel/withdraw actions.

## Local workflow and quality gates
- Bootstrap locally with `bin/setup` (installs gems/yarn and prepares DB).
- CI-style checks are: `bin/rails db:create db:schema:load`, `bundle exec brakeman`, `bundle exec rubocop`, `bundle exec rspec`.
- Run app locally with `bundle exec rails s`; base seed data with `bin/rails db:setup`.
- Useful domain tasks: `bin/rails pvb:populate:visits` (sample visits) and `bin/rails pvb:load_nomis_slots` (backup NOMIS slots).
- The repo still contains Sidekiq references in docs/scripts, but no `sidekiq` gem in `Gemfile.lock`; verify runtime queue assumptions before adding queue-specific code.

## Testing conventions
- Test stack is RSpec + WebMock + VCR (`spec/rails_helper.rb`, `spec/spec_helper.rb`); external HTTP is blocked by default.
- Prefer existing helper conventions: `stub_auth_token`, `switch_on_api`/`switch_off_api`, `mock_nomis_with`, and `prison_login`.
- Use `ActiveJobHelper` in specs when asserting queued work and immediate execution behavior.
- Reporting models backed by Scenic SQL views (`db/views/*.sql`) are read-only and refreshed with `Scenic.database.refresh_materialized_view`.
- Frontend is Sprockets + legacy jQuery/GOV.UK modules (`app/assets/javascripts/application.js`), not a modern JS bundler.