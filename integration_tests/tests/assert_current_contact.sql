select *
from {{ ref('resend', 'dim_resend__contacts') }}
where
    contact_id = 'contact_1'
    and (
        is_unsubscribed is not true
        or latest_event_type != 'contact.updated'
    )
