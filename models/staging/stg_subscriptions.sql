with source as (
    select * from {{ ref('subscriptions') }}
),

renamed as (
    select
        subscription_id,
        customer_id,
        mrr_amount,
        status,
        billing_interval,
        start_date,
        end_date
    from source
)

select * from renamed