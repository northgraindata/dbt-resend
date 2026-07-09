{{ config(enabled=var('resend__using_api_snapshots', false) and var('resend__using_domains_api', true)) }}

select
    cast(id as {{ dbt.type_string() }}) as domain_id,
    cast(name as {{ dbt.type_string() }}) as domain_name,
    cast(status as {{ dbt.type_string() }}) as domain_status,
    cast(region as {{ dbt.type_string() }}) as region,
    {{ resend.cast_timestamp('created_at') }} as domain_created_at
from {{ source('resend_raw', 'api_domains') }}
