{{ config(enabled=var('resend__using_api_snapshots', false) and var('resend__using_broadcasts', true)) }}

select
    cast(id as {{ dbt.type_string() }}) as broadcast_id,
    cast(name as {{ dbt.type_string() }}) as broadcast_name,
    cast(audience_id as {{ dbt.type_string() }}) as audience_id,
    cast(segment_id as {{ dbt.type_string() }}) as segment_id,
    cast(status as {{ dbt.type_string() }}) as broadcast_status,
    {{ resend.cast_timestamp('created_at') }} as broadcast_created_at,
    {{ resend.cast_timestamp('scheduled_at') }} as scheduled_at,
    {{ resend.cast_timestamp('sent_at') }} as sent_at
from {{ source('resend_raw', 'api_broadcasts') }}
