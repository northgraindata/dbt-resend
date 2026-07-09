select *
from {{ ref('resend', 'dim_resend__domains') }}
where
    domain_id = 'domain_1'
    and (
        domain_status != 'verified'
        or latest_event_type != 'domain.updated'
    )
