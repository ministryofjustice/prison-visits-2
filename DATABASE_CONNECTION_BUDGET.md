# Database connection and concurrency budget

## Findings

Both applications share the visits database and maintain separate ActiveRecord
pools per worker process. Staff production defaults are two pods, five workers per
pod, three Puma request threads and five database pool slots per worker. The
public app uses two pods, four workers and five request threads/pool slots per
worker. These are checked-in settings, not verified live process counts.

The staff pool must not automatically shrink to the three Puma request threads.
`ZendeskTicketsJob` and `LoadTestDataRemoverJob` also use the database, and no
non-test queue adapter is configured. Rails' in-process job execution can therefore
compete with web requests for the same pool. No worker, request-thread, queue
adapter or normal web-pool default is reduced in this change.

The public app's direct `Staff::*` fallback also uses the database. Setting an API
URL does not by itself enable `USE_STAFF_API`; this change preserves both paths.
Its Puma file hard-codes four workers, despite the chart importing a
`WEB_CONCURRENCY` secret. This change does not start honouring that secret, which
could unexpectedly increase or reduce workers.

## Independent pool controls

`DB_POOL_SIZE` controls the database YAML pool, falling back to
`RAILS_MAX_THREADS`, then five. HTTP client pool capacity now resolves separately
from `HTTP_POOL_SIZE`, then `RAILS_MAX_THREADS`, then five.

| Environment settings | Database pool | Each HTTP client pool |
| --- | ---: | ---: |
| No overrides | 5 | 5 |
| RAILS_MAX_THREADS=7 | 7 | 7 |
| DB_POOL_SIZE=1 | 1 | 5 |
| HTTP_POOL_SIZE=8 | 5 | 8 |
| DB_POOL_SIZE=3, HTTP_POOL_SIZE=8, RAILS_MAX_THREADS=7 | 3 | 8 |

This separation prevents a database cap from silently throttling NOMIS, Zendesk
or other pooled HTTP integrations. Pool sizes are per pool instance and process,
not an application-wide connection total. Explicit database URL parameters such
as `pool=9` retain Rails' precedence over YAML/DB_POOL_SIZE; boot tests cover this.
Do not assume a DB_POOL_SIZE setting wins over a URL pool override.

## Rollout budget

Both Helm charts change `maxSurge` from `100%` to integer `1`, retaining two steady
replicas and the existing `maxUnavailable: 20%`. At two replicas that unavailable
percentage rounds down to zero, so this does not deliberately remove healthy
serving capacity. It reduces parallel pod replacement and can slow deployments.

Assuming existing worker/thread defaults and no URL/pool overrides:

| Web capacity | Before | After both app changes |
| --- | ---: | ---: |
| Staff steady pool slots | 50 | 50 |
| Public steady pool slots | 40 | 40 |
| Staff during nominal surge | 100 | 75 |
| Public during nominal surge | 80 | 60 |
| Combined nominal overlapping surge | 180 | 135 |

The 25% reduction applies to nominal rollout pool capacity, not steady-state
connections or measured memory. Pools open connections lazily. Kubernetes
terminating pods can exceed the nominal surge population, and jobs, consoles,
maintenance connections, autoscaling and future replicas must be counted
separately. These figures are not a database-wide hard cap.

## Maintenance jobs

The anonymisation, NOMIS slot-load and session-trim CronJobs explicitly set
`DB_POOL_SIZE=1`. Their current task implementations issue database operations
sequentially. Their combined nominal pool budget changes from 15 slots to three,
assuming no URL overrides, without changing HTTP pool capacity, job schedules,
commands, data selection or write semantics. This bounds capacity; it does not
claim each job previously opened five connections.

The load-test cleanup job is deliberately not reduced: it enqueues database-using
jobs and may run them concurrently. Midnight scheduling overlap is unchanged.
If any capped task gains asynchronous database work, reconsider its pool before
deploying that change.

## Validation

- Six real Rails-boot configuration cases passed in each application, using an
  intentionally unreachable database URL. No database connection was needed.
- The final spec path/description was rechecked after formatting and relocation.
- Helm lint and rendering passed for dev, preprod and prod in both applications.
  Rendered resources retained two replicas, maxSurge=1 and existing availability;
  all three staff jobs rendered a string-valued DB_POOL_SIZE of 1.
- Full RuboCop passed in both repositories and Brakeman reported zero warnings.
- Full application/browser suites were not run locally; existing CI runs them.
  Coverage thresholds and queue behaviour were not altered to make checks pass.

## Deployment and rollback

These two application changes are independently deployable and require no schema
migration, database resize, RDS parameter change or new service. The full combined
rollout budget assumes both charts have been deployed; with only one changed,
calculate that application's surge separately. Review actual rendered settings
and readiness behaviour in the normal deployment process, without exposing
credential values.

Rollback by reverting each application/chart change. Reverting the CronJob env
entries restores the previous thread-based database default on its next run.
Existing jobs and web processes retain their configuration until replaced.
Do not reduce normal web pools or database max_connections from these arithmetic
budgets alone. Async jobs, connection checkout waits, query work memory, CPU
credits and user-facing latency still determine whether db.t4g.small is viable.

This step does not merge, alter or depend on the step-one anonymisation or step-two
staff-read branches. No shared development or production database was accessed or
modified during these configuration tests.
