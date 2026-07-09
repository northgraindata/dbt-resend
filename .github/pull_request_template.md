## Summary


## Validation

- [ ] `uv run dbt build --project-dir integration_tests --profiles-dir integration_tests`
- [ ] `uv run yamllint .`
- [ ] `uv run sqlfluff lint models integration_tests`

## Checklist

- [ ] Added or updated tests for behavior changes
- [ ] Updated README or docs for user-facing changes
- [ ] Updated CHANGELOG for release-visible changes
