with source as (
    select * from {{ ref('subscriptions') }}
),

renamed as (
    select
        subscription_id,
        customer_id,
        mrr_amount::number(10, 2) as mrr_amount,
        lower(status) as subscription_status,
        lower(billing_interval) as billing_interval,
        start_date::date as start_date,
        end_date
    from source
)

select * from renamed