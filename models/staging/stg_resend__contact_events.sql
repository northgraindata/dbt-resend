{{ config(enabled=var('resend__using_webhook_events', true)) }}

with source as (

    select * from {{ source('resend_raw', 'webhook_contact_events') }}

),

renamed as (

    select
        cast(svix_id as {{ dbt.type_string() }}) as svix_id,
        cast(event_type as {{ dbt.type_string() }}) as event_type,
        {{ resend.cast_timestamp('event_created_at') }} as event_created_at,
        {{ resend.cast_timestamp('webhook_received_at') }} as webhook_received_at,
        cast({{ resend.json_value('data', '$.id') }} as {{ dbt.type_string() }}) as contact_id,
        cast({{ resend.json_value('data', '$.audience_id') }} as {{ dbt.type_string() }}) as audience_id,
        cast({{ resend.json_value('data', '$.email') }} as {{ dbt.type_string() }}) as email,
        cast({{ resend.json_value('data', '$.first_name') }} as {{ dbt.type_string() }}) as first_name,
        cast({{ resend.json_value('data', '$.last_name') }} as {{ dbt.type_string() }}) as last_name,
        cast({{ resend.json_value('data', '$.unsubscribed') }} as boolean) as is_unsubscribed,
        {{ resend.cast_timestamp(resend.json_value('data', '$.created_at')) }} as contact_created_at,
        {{ resend.cast_timestamp(resend.json_value('data', '$.updated_at')) }} as contact_updated_at,
        {{ resend.json_query('data', '$.segment_ids') }} as segment_ids,
        cast(data as {{ dbt.type_string() }}) as raw_event_data,
        {{ resend.loaded_at() }} as dbt_loaded_at
    from source

)

select * from renamed
