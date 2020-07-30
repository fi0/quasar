# Troubleshooting

## Running Github Actions locally

We compile docs and publish them [here](https://dosomething.github.io/quasar/#!/overview?g_v=1).

These docs are compiled automatically on every push to our `master`(soon to be called `main`) branch by a [Github Action](https://github.com/DoSomething/quasar/actions).

If you need to test the action locally you can do so following the next steps:

- Install [act](https://github.com/nektos/act). Instructions in the link.
- Create an `.env` file with the necessary variables to run the docs compile. See LastPass and look at the [workflow job code](../.github/workflows/dbt-docs.yml) for guidance.
- Locally updating the Github workflow job to get ENV variables from the `env.` context instead of the default `secrets.` context.
    - Example: `PG_DOCS_HOST: ${{ secrets.PG_DOCS_HOST }} -> PG_DOCS_HOST: ${{ env.PG_DOCS_HOST }}`.
- Manually pass the image to use for `Ubuntu-latest` due to a [bug](https://github.com/nektos/act/issues/251#issuecomment-633457052) in the library and the env variables.
    - `ubuntu-latest=nektos/act-environments-ubuntu:18.04`

#### Usage

Run: `act -vP ubuntu-latest=nektos/act-environments-ubuntu:18.04 --env-file ~/.dbt/prod.env`

## How to run DBT schema tests locally against QA Prod data

Model: `phoenix_events.snowplow_base_event`

Command: `pipenv run dbt test --schema -m phoenix_events.snowplow_base_event --profile qa --target prod_dump`

Notes:
- The `.dbt/profiles.yml` has a `qa` profile and a nested `prod_dump` target that points to the `quasar_prod_dump` database (the `default` target would point to the `quasar` database).

```
rpacas@__@$ pipenv run dbt test --schema -m phoenix_events.snowplow_base_event --profile qa --target prod_dump
Running with dbt=0.16.1
Found 51 models, 131 tests, 2 snapshots, 0 analyses, 128 macros, 0 operations, 0 seed files, 25 sources

16:45:39 | Concurrency: 4 threads (target='prod_dump')
16:45:39 |
16:45:39 | 1 of 11 START test not_null_snowplow_base_event_device_id............ [RUN]
16:45:39 | 2 of 11 START test not_null_snowplow_base_event_event_datetime....... [RUN]
16:45:39 | 3 of 11 START test not_null_snowplow_base_event_event_id............. [RUN]
16:45:39 | 4 of 11 START test not_null_snowplow_base_event_event_source......... [RUN]
16:46:20 | 1 of 11 PASS not_null_snowplow_base_event_device_id.................. [PASS in 40.71s]
16:46:20 | 4 of 11 WARN 1 not_null_snowplow_base_event_event_source............. [WARN 1 in 40.70s]
16:46:20 | 5 of 11 START test not_null_snowplow_base_event_event_type........... [RUN]
16:46:20 | 3 of 11 PASS not_null_snowplow_base_event_event_id................... [PASS in 40.70s]
16:46:20 | 2 of 11 PASS not_null_snowplow_base_event_event_datetime............. [PASS in 40.70s]
16:46:20 | 6 of 11 START test not_null_snowplow_base_event_host................. [RUN]
16:46:20 | 7 of 11 START test not_null_snowplow_base_event_path................. [RUN]
16:46:20 | 8 of 11 START test not_null_snowplow_base_event_session_counter...... [RUN]
16:46:59 | 5 of 11 PASS not_null_snowplow_base_event_event_type................. [PASS in 39.10s]
16:46:59 | 6 of 11 WARN 1434 not_null_snowplow_base_event_host.................. [WARN 1434 in 39.10s]
16:46:59 | 8 of 11 PASS not_null_snowplow_base_event_session_counter............ [PASS in 39.09s]
16:46:59 | 7 of 11 WARN 1376 not_null_snowplow_base_event_path.................. [WARN 1376 in 39.09s]
16:46:59 | 9 of 11 START test not_null_snowplow_base_event_session_id........... [RUN]
16:46:59 | 10 of 11 START test relationships_distinct_snowplow_base_event_northstar_id__northstar_id__ref_users_ [RUN]
16:46:59 | 11 of 11 START test unique_snowplow_base_event_event_id.............. [RUN]
16:47:58 | 9 of 11 PASS not_null_snowplow_base_event_session_id................. [PASS in 58.88s]
16:48:08 | 10 of 11 WARN 55927 relationships_distinct_snowplow_base_event_northstar_id__northstar_id__ref_users_ [WARN 55927 in 69.16s]
16:53:11 | 11 of 11 PASS unique_snowplow_base_event_event_id.................... [PASS in 372.12s]
16:53:11 | 
16:53:11 | Finished running 11 tests in 455.76s.

Completed with 4 warnings:

Warning in test not_null_snowplow_base_event_event_source (models/phoenix_events/schema.yml)
  Got 1 result, expected 0.

  compiled SQL at ../../docs/compiled/ds_dbt/schema_test/not_null_snowplow_base_event_event_source.sql

Warning in test not_null_snowplow_base_event_host (models/phoenix_events/schema.yml)
  Got 1434 results, expected 0.

  compiled SQL at ../../docs/compiled/ds_dbt/schema_test/not_null_snowplow_base_event_host.sql

Warning in test not_null_snowplow_base_event_path (models/phoenix_events/schema.yml)
  Got 1376 results, expected 0.

  compiled SQL at ../../docs/compiled/ds_dbt/schema_test/not_null_snowplow_base_event_path.sql

Warning in test relationships_distinct_snowplow_base_event_northstar_id__northstar_id__ref_users_ (models/phoenix_events/schema.yml)
  Got 55927 results, expected 0.

  compiled SQL at ../../docs/compiled/ds_dbt/schema_test/relationships_distinct_snowplow_base_event_a807bb8684014b380960f5018bbec40d.sql

Done. PASS=7 WARN=4 ERROR=0 SKIP=0 TOTAL=11
```
