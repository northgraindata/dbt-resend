{{ config(enabled=var('resend__using_webhook_events', true) or var('resend__using_api_snapshots', false)) }}

with webhook_domains as (

    {% if var('resend__using_webhook_events', true) %}
    select
        domain_id,
        domain_name,
        domain_status,
        region,
        domain_created_at,
        records,
        event_type as latest_event_type,
        event_created_at as latest_event_at
    from {{ ref('int_resend__latest_domain_event') }}
    {% else %}
    select
        cast(null as {{ dbt.type_string() }}) as domain_id,
        cast(null as {{ dbt.type_string() }}) as domain_name,
        cast(null as {{ dbt.type_string() }}) as domain_status,
        cast(null as {{ dbt.type_string() }}) as region,
        cast(null as {{ dbt.type_timestamp() }}) as domain_created_at,
        cast(null as {{ dbt.type_string() }}) as records,
        cast(null as {{ dbt.type_string() }}) as latest_event_type,
        cast(null as {{ dbt.type_timestamp() }}) as latest_event_at
    where false
    {% endif %}

),

api_domains as (

    {% if var('resend__using_api_snapshots', false) and var('resend__using_domains_api', true) %}
    select
        domain_id,
        domain_name,
        domain_status,
        region,
        domain_created_at,
        cast(null as {{ dbt.type_string() }}) as records,
        cast(null as {{ dbt.type_string() }}) as latest_event_type,
        domain_created_at as latest_event_at
    from {{ ref('stg_resend__api_domains') }}
    {% else %}
    select * from webhook_domains where false
    {% endif %}

),

unioned as (

    select *, 1 as source_priority from webhook_domains
    union all
    select *, 2 as source_priority from api_domains

),

ranked as (

    select
        *,
        row_number() over (
            partition by domain_id
            order by source_priority, latest_event_at desc
        ) as source_rank
    from unioned
    where domain_id is not null

)

select
    {{ resend.surrogate_key(['domain_id']) }} as domain_key,
    domain_id,
    domain_name,
    domain_status,
    region,
    domain_created_at,
    records,
    latest_event_type,
    latest_event_at
from ranked
where source_rank = 1
