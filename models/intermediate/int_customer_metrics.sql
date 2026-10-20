with customers as (
    select * from {{ ref('stg_customers') }}
),

subscriptions as (
    select * from {{ ref('stg_subscriptions') }}
),

invoices as (
    select * from {{ ref('stg_invoices') }}
),

customer_aggregates as (
    select
        s.customer_id,
        count(distinct s.subscription_id) as total_subscriptions,
        coalesce(sum(i.amount_due), 0) as total_amount_due,
        coalesce(sum(i.amount_paid), 0) as total_amount_paid,
        max(i.invoice_date) as most_recent_payment_date
    from subscriptions s
    left join invoices i on s.subscription_id = i.subscription_id
    group by 1
),

final as (
    select
        c.customer_id,
        c.company_name,
        c.signup_date,
        c.plan_tier,
        coalesce(ca.total_subscriptions, 0) as total_subscriptions,
        coalesce(ca.total_amount_due, 0) as lifetime_amount_due,
        coalesce(ca.total_amount_paid, 0) as lifetime_amount_paid,
        (coalesce(ca.total_amount_due, 0) - coalesce(ca.total_amount_paid, 0)) as outstanding_balance,
        ca.most_recent_payment_date
    from customers c
    left join customer_aggregates ca on c.customer_id = ca.customer_id
)

select * from final