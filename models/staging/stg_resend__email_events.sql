{{ config(enabled=var('resend__using_webhook_events', true)) }}

with source as (

    select * from {{ source('resend_raw', 'webhook_email_events') }}

),

renamed as (

    select
        cast(svix_id as {{ dbt.type_string() }}) as svix_id,
        cast(event_type as {{ dbt.type_string() }}) as event_type,
        {{ resend.cast_timestamp('event_created_at') }} as event_created_at,
        {{ resend.cast_timestamp('webhook_received_at') }} as webhook_received_at,
        cast({{ resend.json_value('data', '$.email_id') }} as {{ dbt.type_string() }}) as email_id,
        cast({{ resend.json_value('data', '$.message_id') }} as {{ dbt.type_string() }}) as message_id,
        cast({{ resend.json_value('data', '$.broadcast_id') }} as {{ dbt.type_string() }}) as broadcast_id,
        cast({{ resend.json_value('data', '$.template_id') }} as {{ dbt.type_string() }}) as template_id,
        cast({{ resend.json_value('data', '$.from') }} as {{ dbt.type_string() }}) as from_email,
        cast({{ resend.json_value('data', '$.subject') }} as {{ dbt.type_string() }}) as subject,
        {{ resend.cast_timestamp(resend.json_value('data', '$.created_at')) }} as email_created_at,
        {{ resend.json_query('data', '$.to') }} as to_recipients,
        {{ resend.json_query('data', '$.cc') }} as cc_recipients,
        {{ resend.json_query('data', '$.bcc') }} as bcc_recipients,
        {{ resend.json_query('data', '$.received_for') }} as received_for,
        {{ resend.json_query('data', '$.tags') }} as tags,
        {{ resend.json_value('data', '$.click.link') }} as clicked_link,
        {{ resend.json_value('data', '$.click.ipAddress') }} as clicked_ip_address,
        {{ resend.json_value('data', '$.click.userAgent') }} as clicked_user_agent,
        {{ resend.cast_timestamp(resend.json_value('data', '$.click.timestamp')) }} as clicked_at,
        {{ resend.json_value('data', '$.bounce.type') }} as bounce_type,
        {{ resend.json_value('data', '$.bounce.subType') }} as bounce_subtype,
        {{ resend.json_value('data', '$.bounce.message') }} as bounce_message,
        {{ resend.json_query('data', '$.bounce.diagnosticCode') }} as bounce_diagnostic_codes,
        {{ resend.json_query('data', '$.attachments') }} as attachments,
        cast(data as {{ dbt.type_string() }}) as raw_event_data,
        {{ resend.loaded_at() }} as dbt_loaded_at
    from source

)

select * from renamed
