# Anonymisation performance

## Problem and scope

The nightly anonymisation job searches prisoners, visitors and visits for records
created before the six-month cutoff that have not already been anonymised.
The existing service already avoids rewriting records whose eligibility marker
is `REMOVED`. The opportunity is to avoid repeatedly scanning historical data to
find the remaining eligible records.

Production estimates supplied during the investigation were approximately
6.84 million prisoners, 13.65 million visitors and 6.88 million visits. Their
reported main relation sizes total approximately 5.6 GB. These are estimates and
rounded sizes, not measured nightly reads. The supplied production index listing
contained no indexes supporting these eligibility predicates.

The connected development database is small and is not representative of
production. No shared development or production data was modified in this work.

## Changes

Three separate migrations add nonunique partial indexes concurrently:

| Table | Key | Predicate |
| --- | --- | --- |
| prisoners | created_at | first_name <> 'REMOVED' |
| visitors | created_at | first_name <> 'REMOVED' |
| visits | created_at | contact_email_address <> 'REMOVED' |

The predicates intentionally match `FreshnessCalculations` exactly. The cutoff
remains a query condition rather than an index predicate, so the indexes do not
need rebuilding as time advances. Newly anonymised records leave the logical
index population; ordinary vacuum/index maintenance still applies.

Visitor's default display ordering otherwise makes ActiveRecord express its
bulk update through an ordered ID subquery. `reorder(nil)` is applied only to
this bulk update to remove that ordering. This avoids an unnecessary query shape
without changing visitor display order elsewhere or the set of eligible rows.
It does not add batching or change the update's atomicity.

There are no changes to scheduling, retention, callbacks, audit records,
eligibility markers, replacement values or timestamps. In particular, existing
partially anonymised records are still excluded according to the same marker
rules, and records exactly at the cutoff remain excluded.

## Validation

Completed local checks used disposable Ruby 3.4.8 and PostgreSQL 18 containers:

- Focused anonymisation specs: 19 examples, zero failures.
- Concurrent migration up, rollback and re-application succeeded.
- Loading the updated schema into a fresh database and running the focused specs
  succeeded.
- RuboCop passed and Brakeman reported zero warnings.
- Actual generated update SQL was inspected, including the visitor default scope.

A synthetic one-million-row history with 99% of records already anonymised and
1,000 eligible records was used to investigate access paths. For the tested
selection predicates, a generic prepared plan changed from a parallel scan
touching 33,358 shared blocks to an index scan touching 39. Each synthetic partial
index occupied 88 KiB.

The visitor update was also compared using the actual ActiveRecord SQL shapes:

| Variant | Reported buffer accesses |
| --- | ---: |
| Original update | 78,510 |
| Partial index only | 43,860 |
| Partial index and local ordering removal | 8,113 |

Each variant targeted the same 1,000 synthetic records. Buffer accesses are not
unique physical reads or production timings. These results demonstrate an access
path opportunity, not guaranteed production savings: active-data proportions,
statistics, cache state, concurrency and update/index maintenance costs matter.
The production indexes will include all non-anonymised records, not just records
already older than the cutoff, and may be much larger than the synthetic indexes.

The full local RSpec run was interrupted and was not rerun. The GitHub Actions
pipeline runs database schema setup, Brakeman, RuboCop and the full RSpec suite on
branch pushes. Its PostgreSQL service currently uses version 15.12, so CI also
provides a different-version compatibility check; no successful CI result is
claimed here. CI's schema load does not replace the local migration rollback
checks.

## Deployment and recovery

1. Deploy the migrations through the normal database migration process. Each
   uses `disable_ddl_transaction!` and `algorithm: :concurrently`; do not wrap the
   migration run in an external transaction.
2. Each migration allows 30 minutes for statements, overriding the migration
   safety library's short default. The existing lock timeout is unchanged.
   This is a bound, not a prediction of production build duration.
3. Build during a suitable operational window, avoiding overlap with the nightly
   maintenance jobs where possible. Concurrent creation still scans tables and
   consumes I/O, CPU, disk and WAL; it is not impact-free.
4. After completion, verify all three indexes are valid and ready and the expected
   migrations are recorded. Check anonymisation results and completion time on
   subsequent scheduled runs.
5. If an index build fails or times out, inspect both index validity and migration
   status before retrying. PostgreSQL can leave an invalid index with the requested
   name. Remove only the failed new index concurrently under an approved recovery
   procedure, then retry the affected migration. Do not blindly retry or drop
   pre-existing indexes.
6. The three migrations are separately reversible. Roll back the new indexes
   concurrently if required; revert the local visitor ordering change through a
   normal application deployment if necessary. Do not undo unrelated migrations.

This optimisation does not establish that production can safely run on
`db.t4g.small`. It addresses one source of avoidable database work without claiming
to resolve connection, memory, CPU-credit or other workload constraints.