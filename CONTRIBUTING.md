# Contributing

Thanks for helping improve `dbt-resend`.

## Development

Install dependencies:

```bash
uv sync
```

Run the integration suite:

```bash
uv run dbt deps --project-dir integration_tests --profiles-dir integration_tests
uv run dbt seed --project-dir integration_tests --profiles-dir integration_tests
uv run dbt build --project-dir integration_tests --profiles-dir integration_tests
```

Run lint checks:

```bash
uv run yamllint .
uv run sqlfluff lint models integration_tests
```

## Pull Requests

- Keep changes focused.
- Add or update fixture data for behavioral changes.
- Update `README.md` and `CHANGELOG.md` for user-facing changes.
- Do not include credentials, API keys, or warehouse-specific secrets.
