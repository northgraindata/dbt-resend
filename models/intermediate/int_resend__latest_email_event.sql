{{ config(enabled=var('resend__using_webhook_events', true)) }}

with ranked as (

    select
        *,
        row_number() over (
            partition by email_id
            order by event_created_at desc, webhook_received_at desc, svix_id desc
        ) as event_rank
    from {{ ref('stg_resend__email_events') }}

)

select * from ranked where event_rank = 1
