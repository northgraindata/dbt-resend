{% macro cast_timestamp(expression) -%}
  {{ return(adapter.dispatch('cast_timestamp', 'resend')(expression)) }}
{%- endmacro %}

{% macro default__cast_timestamp(expression) -%}
  cast({{ expression }} as {{ dbt.type_timestamp() }})
{%- endmacro %}

{% macro bigquery__cast_timestamp(expression) -%}
  safe_cast({{ expression }} as timestamp)
{%- endmacro %}

{% macro snowflake__cast_timestamp(expression) -%}
  try_to_timestamp_tz({{ expression }})
{%- endmacro %}

{% macro duckdb__cast_timestamp(expression) -%}
  try_cast({{ expression }} as timestamp)
{%- endmacro %}
