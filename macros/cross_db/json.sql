{% macro json_value(column_name, path) -%}
  {{ return(adapter.dispatch('json_value', 'resend')(column_name, path)) }}
{%- endmacro %}

{% macro default__json_value(column_name, path) -%}
  json_value({{ column_name }}, '{{ path }}')
{%- endmacro %}

{% macro bigquery__json_value(column_name, path) -%}
  json_value({{ column_name }}, '{{ path }}')
{%- endmacro %}

{% macro snowflake__json_value(column_name, path) -%}
  {{ column_name }}:{{ path | replace('$.', '') }}::string
{%- endmacro %}

{% macro postgres__json_value(column_name, path) -%}
  jsonb_path_query_first({{ column_name }}::jsonb, '{{ path }}') #>> '{}'
{%- endmacro %}

{% macro duckdb__json_value(column_name, path) -%}
  json_extract_string({{ column_name }}, '{{ path }}')
{%- endmacro %}

{% macro json_query(column_name, path) -%}
  {{ return(adapter.dispatch('json_query', 'resend')(column_name, path)) }}
{%- endmacro %}

{% macro default__json_query(column_name, path) -%}
  json_query({{ column_name }}, '{{ path }}')
{%- endmacro %}

{% macro bigquery__json_query(column_name, path) -%}
  json_query({{ column_name }}, '{{ path }}')
{%- endmacro %}

{% macro snowflake__json_query(column_name, path) -%}
  {{ column_name }}:{{ path | replace('$.', '') }}
{%- endmacro %}

{% macro postgres__json_query(column_name, path) -%}
  jsonb_path_query_first({{ column_name }}::jsonb, '{{ path }}')
{%- endmacro %}

{% macro duckdb__json_query(column_name, path) -%}
  json_extract({{ column_name }}, '{{ path }}')
{%- endmacro %}
