{{ config(enabled=var('resend__using_api_snapshots', false)) }}

select
    cast(id as {{ dbt.type_string() }}) as contact_id,
    cast(email as {{ dbt.type_string() }}) as email,
    cast(first_name as {{ dbt.type_string() }}) as first_name,
    cast(last_name as {{ dbt.type_string() }}) as last_name,
    cast(unsubscribed as boolean) as is_unsubscribed,
    {{ resend.cast_timestamp('created_at') }} as contact_created_at
from {{ source('resend_raw', 'api_contacts') }}
