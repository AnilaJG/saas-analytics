with customer_metrics as (
    select * from {{ ref('int_customer_metrics') }}
),

final as (
    select
        customer_id,
        company_name,
        signup_date,
        plan_tier,
        total_subscriptions,
        lifetime_amount_due,
        lifetime_amount_paid,
        outstanding_balance,
        most_recent_payment_date,
        case
            when most_recent_payment_date >= current_date() - interval '90 days' then 'active'
            when most_recent_payment_date is null then 'prospect'
            else 'churned'
        end as customer_status
    from customer_metrics
)

select * from final