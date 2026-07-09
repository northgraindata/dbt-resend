{{ config(enabled=var('resend__using_webhook_events', true)) }}

with source as (

    select * from {{ source('resend_raw', 'webhook_domain_events') }}

),

renamed as (

    select
        cast(svix_id as {{ dbt.type_string() }}) as svix_id,
        cast(event_type as {{ dbt.type_string() }}) as event_type,
        {{ resend.cast_timestamp('event_created_at') }} as event_created_at,
        {{ resend.cast_timestamp('webhook_received_at') }} as webhook_received_at,
        cast({{ resend.json_value('data', '$.id') }} as {{ dbt.type_string() }}) as domain_id,
        cast({{ resend.json_value('data', '$.name') }} as {{ dbt.type_string() }}) as domain_name,
        cast({{ resend.json_value('data', '$.status') }} as {{ dbt.type_string() }}) as domain_status,
        cast({{ resend.json_value('data', '$.region') }} as {{ dbt.type_string() }}) as region,
        {{ resend.cast_timestamp(resend.json_value('data', '$.created_at')) }} as domain_created_at,
        {{ resend.json_query('data', '$.records') }} as records,
        cast(data as {{ dbt.type_string() }}) as raw_event_data,
        {{ resend.loaded_at() }} as dbt_loaded_at
    from source

)

select * from renamed
