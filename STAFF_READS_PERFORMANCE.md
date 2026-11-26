# Staff-facing database reads

## Evidence and scope

Production estimates supplied during investigation were approximately 6.88 million
visits, 6.84 million prisoners and 1.17 million messages. The reported main message
relation was 434 MB. The production index listing showed no prisoner-number,
visit-prisoner or message-visit indexes, and no dashboard filter/order indexes.

`EstateVisitQuery` searches by prisoner number or booking reference using an `OR`
across two joined tables. This can stop otherwise selective indexes from being
used effectively. Requested dashboards filter by prison and processing state and
order by creation date. Processed dashboards filter by prison and recent update
date, with cancellation rules and a global result limit. Visit details preload
messages using `visit_id`, for which messages previously had no index.

This branch starts from main and is independent of the anonymisation changes.
No shared development or production database was changed. All execution tests and
benchmarks used disposable local databases with synthetic data.

## Query change

Search now uses a union of matching visit IDs from prisoner-number and reference
lookups. Each branch retains the incoming estate, state, cancellation and date
conditions. Ordering, association preloads and limits remain on the outer query,
so the limit applies after both kinds of match are combined. IDs are not loaded
into Ruby or fetched through separate application queries.

`UNION` removes duplicate IDs when both identifiers match a visit. The original
outer prisoner join remains, preserving its exclusion of missing prisoner rows.
The six-month boundary still uses `updated_at`, not `created_at`. Identifier
normalisation remains uppercase with surrounding whitespace removed; matching
does not become a prefix, pattern or fuzzy search.

The prisoner-number comparison uses an Arel-quoted literal, not SQL interpolation.
This is intentional: a generic prepared plan using an unknown number estimated
the heavily repeated `REMOVED` value poorly in testing. Keeping that safely quoted
value visible allows PostgreSQL to use its value-frequency statistics. This means
different prisoner-number searches can have different prepared SQL text; it is a
planning/cache tradeoff rather than a free optimisation. Reference matching and
the other conditions continue to use the existing query-building conventions.

## Indexes

Each index has a separate reversible migration using concurrent creation and
removal, with DDL transactions disabled:

| Table | Nonunique index columns | Purpose |
| --- | --- | --- |
| prisoners | number | Find all prisoner records sharing a number |
| visits | prisoner_id | Find visits for matching prisoner records |
| messages | visit_id | Per-visit preload and message retrieval |
| visits | prison_id, processing_state, created_at | Requested dashboard filtering |
| visits | prison_id, updated_at | Recent processed-visit filtering |

No unique constraints, foreign keys, existing indexes, reporting views, controller
limits or business rules are removed or changed. The dashboard indexes can reduce
the rows retrieved before sorting; they do not guarantee a sort-free global order
across multiple prisons or accelerate every cancelled/printed-visit query.

These indexes add storage, WAL and write maintenance. In particular, updating
`updated_at` or `processing_state` now maintains an additional index and can affect
HOT-update eligibility. Read improvements must not be interpreted as an equal
reduction in total application CPU or memory use.

## Synthetic checks

Ruby 3.4.8 and PostgreSQL 18 were used with 200,000 synthetic visits/prisoners,
139 estates/prisons and, for the message comparison, 400,000 messages. Visits were
distributed over five years and several states; 20% of prisoner records used the
`REMOVED` marker, and ordinary numbers could match multiple prisoner records.
These distributions are illustrative, not a reproduction of production traffic.

The final Rails-generated processed-search SQL was tested using forced generic
prepared plans. Results and ordering matched the original query for all three
inputs below:

| Search input | Original shared blocks | Final shared blocks |
| --- | ---: | ---: |
| Ordinary prisoner number | 2,020 | 44 |
| Booking reference | 2,020 | 25 |
| Common REMOVED marker | 2,101 | 1,146 |

An intermediate parameterised union was rejected after it touched 177,106 blocks
for `REMOVED`. The final quoted-value form avoided that regression. With the new
indexes but the original query, `REMOVED` touched 806 blocks, so the final union
is not the best strategy for every value. Its benefit in this fixture is greatest
for selective operational searches.

Separate access-path comparisons produced:

| Operation | Before shared blocks | With candidate indexes |
| --- | ---: | ---: |
| Per-visit message lookup | 9,757 | 5 |
| Requested dashboard | 1,446 | 21 |
| Processed dashboard | 1,733 | 441 |

Shared-block accesses include cache hits and reads and can count the same block
multiple times. They are not unique physical reads or production latency claims.
Result-set equivalence was checked, no planner methods were disabled, and scratch
schemas were removed after the comparisons. Production performance still depends
on data distribution, statistics, cache state, concurrency and writes.

## Regression validation

Focused specs were run individually using the repository's existing single-file
mode, avoiding the whole-application coverage gate without changing CI policy:

- EstateVisitQuery: 57 examples, zero failures.
- Message: 3 examples, zero failures.
- Dashboard controller: 8 examples, zero failures.
- Visit controller: 9 examples, zero failures.
- Visit model: 41 examples, zero failures.
- Visit timeline: 3 examples, zero failures.
- Booked-visit CSV exporter: 3 examples, zero failures.

Coverage includes identifier collisions, duplicate prisoner numbers, both-branch
matches, state/cancellation exclusions, other estates, update-date eligibility,
normalisation, exact matching, preload preservation, global ordering/limits and
all five index definitions. A SQL-shape regression protects the quoted
prisoner-number predicate used for skew-aware generic planning.

All five migrations were applied, rolled back and re-applied in isolation. Loading
the checked-in schema into a fresh database also passed the query specs. RuboCop
passed and Brakeman reported zero warnings. The full RSpec/browser suite was not
run locally; the existing pipeline runs it on branch pushes. Local validation used
PostgreSQL 18, while the pipeline currently uses PostgreSQL 15.12.

## Rollout and recovery

Apply the five migrations before enabling the rewritten search. The old query
continues to work while the indexes are built. Concurrent builds still read large
tables, consume disk/WAL and may wait for existing transactions. Each migration
allows 30 minutes per statement; this does not predict production build duration
or remove the existing short lock timeout. Avoid overlapping index builds with
the nightly maintenance peak where operationally possible.

Confirm each new index is valid and ready and the corresponding migration is
recorded before continuing. A failed concurrent build can leave an invalid index
with the intended name: inspect validity and migration status, remove only that
failed new index concurrently under an approved recovery procedure, then retry.
Do not automatically drop existing indexes or repeatedly retry failed builds.

The application query change can be reverted independently while keeping the
indexes. The index migrations can then be reversed individually using concurrent
removal; do not roll back unrelated migrations. This branch does not establish
that production is ready for `db.t4g.small`, change the connection budget, or
perform any live infrastructure changes.