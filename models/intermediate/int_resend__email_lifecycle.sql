{{ config(enabled=var('resend__using_webhook_events', true)) }}

with events as (

    select * from {{ ref('stg_resend__email_events') }}

),

aggregated as (

    select
        email_id,
        min(email_created_at) as email_created_at,
        min(case when event_type = 'email.scheduled' then event_created_at end) as first_scheduled_at,
        min(case when event_type = 'email.sent' then event_created_at end) as first_sent_at,
        min(case when event_type = 'email.delivered' then event_created_at end) as first_delivered_at,
        min(case when event_type = 'email.opened' then event_created_at end) as first_opened_at,
        min(case when event_type = 'email.clicked' then event_created_at end) as first_clicked_at,
        min(case when event_type = 'email.bounced' then event_created_at end) as first_bounced_at,
        min(case when event_type = 'email.complained' then event_created_at end) as first_complained_at,
        min(case when event_type = 'email.failed' then event_created_at end) as first_failed_at,
        min(case when event_type = 'email.received' then event_created_at end) as first_received_at,
        count(*) as event_count,
        sum(case when event_type = 'email.opened' then 1 else 0 end) as open_count,
        sum(case when event_type = 'email.clicked' then 1 else 0 end) as click_count
    from events
    group by 1

)

select * from aggregated
