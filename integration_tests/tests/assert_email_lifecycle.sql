select *
from {{ ref('resend', 'dim_resend__emails') }}
where
    email_id = 'email_1'
    and (
        open_count != 1
        or click_count != 1
        or latest_event_type != 'email.clicked'
    )
