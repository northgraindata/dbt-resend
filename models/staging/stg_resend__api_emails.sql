{{ config(enabled=var('resend__using_api_snapshots', false)) }}

select
    cast(id as {{ dbt.type_string() }}) as email_id,
    cast(message_id as {{ dbt.type_string() }}) as message_id,
    cast({{ adapter.quote('from') }} as {{ dbt.type_string() }}) as from_email,
    cast(subject as {{ dbt.type_string() }}) as subject,
    cast(last_event as {{ dbt.type_string() }}) as last_event,
    {{ resend.cast_timestamp('created_at') }} as email_created_at,
    {{ resend.cast_timestamp('scheduled_at') }} as scheduled_at,
    cast({{ adapter.quote('to') }} as {{ dbt.type_string() }}) as to_recipients,
    cast(cc as {{ dbt.type_string() }}) as cc_recipients,
    cast(bcc as {{ dbt.type_string() }}) as bcc_recipients,
    cast(reply_to as {{ dbt.type_string() }}) as reply_to
from {{ source('resend_raw', 'api_emails') }}
