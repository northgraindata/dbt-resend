{% macro surrogate_key(fields) -%}
  {{ return(adapter.dispatch('surrogate_key', 'resend')(fields)) }}
{%- endmacro %}

{% macro default__surrogate_key(fields) -%}
  md5(
    {%- for field in fields -%}
      coalesce(cast({{ field }} as {{ dbt.type_string() }}), '')
      {%- if not loop.last %} || '|' || {% endif -%}
    {%- endfor -%}
  )
{%- endmacro %}

{% macro bigquery__surrogate_key(fields) -%}
  to_hex(md5(
    {%- for field in fields -%}
      coalesce(cast({{ field }} as string), '')
      {%- if not loop.last %} || '|' || {% endif -%}
    {%- endfor -%}
  ))
{%- endmacro %}
