{{ config(enabled=var('resend__using_webhook_events', true) or var('resend__using_api_snapshots', false)) }}

with webhook_contacts as (

    {% if var('resend__using_webhook_events', true) %}
    select
        contact_id,
        audience_id,
        email,
        first_name,
        last_name,
        is_unsubscribed,
        contact_created_at,
        contact_updated_at,
        segment_ids,
        event_type as latest_event_type,
        event_created_at as latest_event_at
    from {{ ref('int_resend__latest_contact_event') }}
    {% else %}
    select
        cast(null as {{ dbt.type_string() }}) as contact_id,
        cast(null as {{ dbt.type_string() }}) as audience_id,
        cast(null as {{ dbt.type_string() }}) as email,
        cast(null as {{ dbt.type_string() }}) as first_name,
        cast(null as {{ dbt.type_string() }}) as last_name,
        cast(null as boolean) as is_unsubscribed,
        cast(null as {{ dbt.type_timestamp() }}) as contact_created_at,
        cast(null as {{ dbt.type_timestamp() }}) as contact_updated_at,
        cast(null as {{ dbt.type_string() }}) as segment_ids,
        cast(null as {{ dbt.type_string() }}) as latest_event_type,
        cast(null as {{ dbt.type_timestamp() }}) as latest_event_at
    where false
    {% endif %}

),

api_contacts as (

    {% if var('resend__using_api_snapshots', false) %}
    select
        contact_id,
        cast(null as {{ dbt.type_string() }}) as audience_id,
        email,
        first_name,
        last_name,
        is_unsubscribed,
        contact_created_at,
        cast(null as {{ dbt.type_timestamp() }}) as contact_updated_at,
        cast(null as {{ dbt.type_string() }}) as segment_ids,
        cast(null as {{ dbt.type_string() }}) as latest_event_type,
        contact_created_at as latest_event_at
    from {{ ref('stg_resend__api_contacts') }}
    {% else %}
    select * from webhook_contacts where false
    {% endif %}

),

unioned as (

    select *, 1 as source_priority from webhook_contacts
    union all
    select *, 2 as source_priority from api_contacts

),

ranked as (

    select
        *,
        row_number() over (
            partition by contact_id
            order by source_priority, latest_event_at desc
        ) as source_rank
    from unioned
    where contact_id is not null

)

select
    {{ resend.surrogate_key(['contact_id']) }} as contact_key,
    contact_id,
    audience_id,
    email,
    first_name,
    last_name,
    is_unsubscribed,
    contact_created_at,
    contact_updated_at,
    segment_ids,
    latest_event_type,
    latest_event_at
from ranked
where source_rank = 1
