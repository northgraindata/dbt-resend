{{ config(enabled=var('resend__using_api_snapshots', false) and var('resend__using_broadcasts', true)) }}

select
    {{ resend.surrogate_key(['broadcast_id']) }} as broadcast_key,
    broadcast_id,
    broadcast_name,
    audience_id,
    segment_id,
    broadcast_status,
    broadcast_created_at,
    scheduled_at,
    sent_at
from {{ ref('stg_resend__api_broadcasts') }}
