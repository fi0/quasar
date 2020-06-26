## Troubleshooting

### Running Github Actions locally

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
