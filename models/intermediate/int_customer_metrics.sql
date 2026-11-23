with customers as (
    select * from {{ ref('stg_customers') }}
),

subscriptions as (
    select * from {{ ref('stg_subscriptions') }}
),

invoices as (
    select * from {{ ref('stg_invoices') }}
),

subscription_summary as (
    select
        customer_id,
        count(distinct subscription_id) as total_subscriptions,
        count_if(
            start_date <= '{{ var("as_of_date") }}'
            and (end_date is null or end_date > '{{ var("as_of_date") }}')
        ) as active_subscriptions
    from subscriptions
    group by 1
),

invoice_summary as (
    select
        customer_id,
        sum(amount_due) as total_amount_due,
        sum(amount_paid) as total_amount_paid,
        max(case when amount_paid > 0 then invoice_date end) as most_recent_payment_date
    from invoices
    group by 1
),

final as (
    select
        c.customer_id,
        c.company_name,
        c.signup_date,
        c.plan_tier,
        coalesce(s.total_subscriptions, 0) as total_subscriptions,
        coalesce(i.total_amount_due, 0) as lifetime_amount_due,
        coalesce(i.total_amount_paid, 0) as lifetime_amount_paid,
        coalesce(i.total_amount_due, 0) - coalesce(i.total_amount_paid, 0) as outstanding_balance,
        i.most_recent_payment_date,
        case
            when coalesce(s.active_subscriptions, 0) > 0 then 'active'
            when coalesce(s.total_subscriptions, 0) > 0 then 'churned'
            else 'prospect'
        end as customer_status
    from customers c
    left join subscription_summary s on c.customer_id = s.customer_id
    left join invoice_summary i on c.customer_id = i.customer_id
)

select * from final