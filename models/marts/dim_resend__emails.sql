{{ config(enabled=var('resend__using_webhook_events', true) or var('resend__using_api_snapshots', false)) }}

with webhook_emails as (

    {% if var('resend__using_webhook_events', true) %}
    select
        latest.email_id,
        latest.message_id,
        latest.broadcast_id,
        latest.template_id,
        latest.from_email,
        latest.subject,
        lifecycle.email_created_at,
        lifecycle.first_scheduled_at,
        lifecycle.first_sent_at,
        lifecycle.first_delivered_at,
        lifecycle.first_opened_at,
        lifecycle.first_clicked_at,
        lifecycle.first_bounced_at,
        lifecycle.first_complained_at,
        lifecycle.first_failed_at,
        lifecycle.first_received_at,
        latest.event_type as latest_event_type,
        latest.event_created_at as latest_event_at,
        lifecycle.event_count,
        lifecycle.open_count,
        lifecycle.click_count,
        latest.to_recipients,
        latest.cc_recipients,
        latest.bcc_recipients,
        latest.tags
    from {{ ref('int_resend__latest_email_event') }} as latest
    left join {{ ref('int_resend__email_lifecycle') }} as lifecycle
        on latest.email_id = lifecycle.email_id
    {% else %}
    select
        cast(null as {{ dbt.type_string() }}) as email_id,
        cast(null as {{ dbt.type_string() }}) as message_id,
        cast(null as {{ dbt.type_string() }}) as broadcast_id,
        cast(null as {{ dbt.type_string() }}) as template_id,
        cast(null as {{ dbt.type_string() }}) as from_email,
        cast(null as {{ dbt.type_string() }}) as subject,
        cast(null as {{ dbt.type_timestamp() }}) as email_created_at,
        cast(null as {{ dbt.type_timestamp() }}) as first_scheduled_at,
        cast(null as {{ dbt.type_timestamp() }}) as first_sent_at,
        cast(null as {{ dbt.type_timestamp() }}) as first_delivered_at,
        cast(null as {{ dbt.type_timestamp() }}) as first_opened_at,
        cast(null as {{ dbt.type_timestamp() }}) as first_clicked_at,
        cast(null as {{ dbt.type_timestamp() }}) as first_bounced_at,
        cast(null as {{ dbt.type_timestamp() }}) as first_complained_at,
        cast(null as {{ dbt.type_timestamp() }}) as first_failed_at,
        cast(null as {{ dbt.type_timestamp() }}) as first_received_at,
        cast(null as {{ dbt.type_string() }}) as latest_event_type,
        cast(null as {{ dbt.type_timestamp() }}) as latest_event_at,
        cast(null as integer) as event_count,
        cast(null as integer) as open_count,
        cast(null as integer) as click_count,
        cast(null as {{ dbt.type_string() }}) as to_recipients,
        cast(null as {{ dbt.type_string() }}) as cc_recipients,
        cast(null as {{ dbt.type_string() }}) as bcc_recipients,
        cast(null as {{ dbt.type_string() }}) as tags
    where false
    {% endif %}

),

api_emails as (

    {% if var('resend__using_api_snapshots', false) %}
    select
        email_id,
        message_id,
        cast(null as {{ dbt.type_string() }}) as broadcast_id,
        cast(null as {{ dbt.type_string() }}) as template_id,
        from_email,
        subject,
        email_created_at,
        scheduled_at as first_scheduled_at,
        cast(null as {{ dbt.type_timestamp() }}) as first_sent_at,
        cast(null as {{ dbt.type_timestamp() }}) as first_delivered_at,
        cast(null as {{ dbt.type_timestamp() }}) as first_opened_at,
        cast(null as {{ dbt.type_timestamp() }}) as first_clicked_at,
        cast(null as {{ dbt.type_timestamp() }}) as first_bounced_at,
        cast(null as {{ dbt.type_timestamp() }}) as first_complained_at,
        cast(null as {{ dbt.type_timestamp() }}) as first_failed_at,
        cast(null as {{ dbt.type_timestamp() }}) as first_received_at,
        last_event as latest_event_type,
        email_created_at as latest_event_at,
        cast(null as integer) as event_count,
        cast(null as integer) as open_count,
        cast(null as integer) as click_count,
        to_recipients,
        cc_recipients,
        bcc_recipients,
        cast(null as {{ dbt.type_string() }}) as tags
    from {{ ref('stg_resend__api_emails') }}
    {% else %}
    select * from webhook_emails where false
    {% endif %}

),

unioned as (

    select *, 1 as source_priority from webhook_emails
    union all
    select *, 2 as source_priority from api_emails

),

ranked as (

    select
        *,
        row_number() over (
            partition by email_id
            order by source_priority, latest_event_at desc
        ) as source_rank
    from unioned
    where email_id is not null

)

select
    {{ resend.surrogate_key(['email_id']) }} as email_key,
    email_id,
    message_id,
    broadcast_id,
    template_id,
    from_email,
    subject,
    email_created_at,
    first_scheduled_at,
    first_sent_at,
    first_delivered_at,
    first_opened_at,
    first_clicked_at,
    first_bounced_at,
    first_complained_at,
    first_failed_at,
    first_received_at,
    latest_event_type,
    latest_event_at,
    event_count,
    open_count,
    click_count,
    to_recipients,
    cc_recipients,
    bcc_recipients,
    tags
from ranked
where source_rank = 1
