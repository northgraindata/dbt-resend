{% macro loaded_at() -%}
  {{ return(adapter.dispatch('loaded_at', 'resend')()) }}
{%- endmacro %}

{% macro default__loaded_at() -%}
  current_timestamp
{%- endmacro %}

{% macro bigquery__loaded_at() -%}
  current_timestamp()
{%- endmacro %}
