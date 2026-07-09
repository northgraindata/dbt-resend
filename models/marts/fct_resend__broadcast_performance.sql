{{ config(enabled=var('resend__using_webhook_events', true)) }}

select
    {{ resend.surrogate_key(['broadcast_id']) }} as broadcast_key,
    broadcast_id,
    count(distinct email_id) as email_count,
    sum(case when event_type = 'email.sent' then 1 else 0 end) as sent_count,
    sum(case when event_type = 'email.delivered' then 1 else 0 end) as delivered_count,
    sum(case when event_type = 'email.opened' then 1 else 0 end) as opened_count,
    sum(case when event_type = 'email.clicked' then 1 else 0 end) as clicked_count,
    sum(case when event_type = 'email.bounced' then 1 else 0 end) as bounced_count,
    sum(case when event_type = 'email.complained' then 1 else 0 end) as complained_count,
    sum(case when event_type = 'email.failed' then 1 else 0 end) as failed_count
from {{ ref('stg_resend__email_events') }}
where broadcast_id is not null
group by 1, 2
