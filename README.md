# Resend DBT Package

This [dbt](https://www.getdbt.com/) package models raw [Resend](https://resend.com/) webhook events and optional API snapshot tables into analytics-ready email, contact, domain, and broadcast models.

Features include:
- Clean staging models for Resend webhook email, contact, and domain events
- Current-state dimensions for emails, contacts, and domains
- Email lifecycle timestamps for sent, delivered, opened, clicked, bounced, complained, failed, received, and scheduled events
- Daily email engagement and broadcast performance facts
- Optional API snapshot support for sent emails, contacts, broadcasts, and domains
- Cross-database helper macros for JSON extraction, timestamp casting, and stable keys
- DuckDB integration fixtures for local development and CI

## Models

| model | description |
|-------|-------------|
| `stg_resend__email_events` | Cleaned email webhook events with common Resend payload fields extracted. |
| `stg_resend__contact_events` | Cleaned contact lifecycle webhook events. |
| `stg_resend__domain_events` | Cleaned domain lifecycle webhook events. |
| `stg_resend__api_emails` | Optional snapshot of the Resend List Sent Emails API. |
| `stg_resend__api_contacts` | Optional snapshot of the Resend List Contacts API. |
| `stg_resend__api_broadcasts` | Optional snapshot of the Resend List Broadcasts API. |
| `stg_resend__api_domains` | Optional snapshot of the Resend List Domains API. |
| `dim_resend__emails` | Current email dimension with lifecycle timestamps and engagement counts. |
| `dim_resend__contacts` | Current contact dimension. |
| `dim_resend__domains` | Current domain dimension. |
| `dim_resend__broadcasts` | Optional broadcast dimension from API snapshots. |
| `fct_resend__email_events` | One row per Resend email webhook event. |
| `fct_resend__email_engagement_daily` | Daily event counts by broadcast and template. |
| `fct_resend__broadcast_performance` | Broadcast-level send, delivery, open, click, bounce, complaint, and failure counts. |

## Installation

### Install from dbt Package Hub

After the first stable release is published to dbt Hub, add this to your `packages.yml`:

```yaml
packages:
  - package: northgraindata/resend
    version: [">=0.1.0", "<0.2.0"]
```

Run:

```bash
dbt deps
```

### Install from GitHub

```yaml
packages:
  - git: "https://github.com/northgraindata/dbt-resend.git"
    revision: 0.1.0
```

### Install from a Local Directory

```yaml
packages:
  - local: ../dbt-resend
```

## Required Variables

The package assumes Resend data has already been loaded into your warehouse. It does not call the Resend API from dbt.

By default, webhook models expect the table names used by Resend's webhook ingester:

```yaml
vars:
  resend_source_schema: raw_resend
  resend_webhook_email_identifier: resend_wh_emails
  resend_webhook_contact_identifier: resend_wh_contacts
  resend_webhook_domain_identifier: resend_wh_domains
```

Each webhook table must include:

| column | description |
|--------|-------------|
| `svix_id` | Unique webhook delivery ID used for idempotency. |
| `event_type` | Resend webhook event type, such as `email.delivered`. |
| `event_created_at` | Timestamp when Resend created the event. |
| `webhook_received_at` | Timestamp when your ingestion layer received the event. |
| `data` | Event-specific JSON payload. |

## Optional API Snapshots

Enable API snapshot models when your ELT process also loads Resend list endpoints:

```yaml
vars:
  resend__using_api_snapshots: true
  resend_api_emails_identifier: resend_api_emails
  resend_api_contacts_identifier: resend_api_contacts
  resend_api_broadcasts_identifier: resend_api_broadcasts
  resend_api_domains_identifier: resend_api_domains
```

Webhook data takes precedence over API snapshots when both sources provide the same entity because webhook events include the richest lifecycle history.

## Supported Warehouses

This package is designed for cross-database dbt usage through adapter-dispatched macros. The included integration test suite runs on DuckDB. BigQuery, Snowflake, and Postgres support are implemented through dispatch macros and should be validated against your warehouse before production rollout.

## Development

This project uses [uv](https://docs.astral.sh/uv/).

```bash
uv sync
uv run dbt deps --project-dir integration_tests --profiles-dir integration_tests
uv run dbt seed --project-dir integration_tests --profiles-dir integration_tests
uv run dbt build --project-dir integration_tests --profiles-dir integration_tests
```

To lint:

```bash
uv run yamllint .
uv run sqlfluff lint models integration_tests
```

## Publishing to dbt Hub

1. Update `version` in `dbt_project.yml`.
2. Update `CHANGELOG.md`.
3. Create a semver Git tag and GitHub release.
4. Add the package to the dbt Hub registry following the current dbt guidance.

dbt Hub packages should use bounded minor version install examples so downstream projects receive patch updates without unreviewed minor upgrades.
