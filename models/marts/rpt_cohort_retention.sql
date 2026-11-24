with customer_mrr as (
    select * from {{ ref('fct_mrr_monthly') }}
),

first_paid_month as (
    select
        customer_id,
        min(month_start_date) as first_paid_month
    from customer_mrr
    where is_paying = true
    group by 1
),

cohort_activity as (
    select
        date_trunc('quarter', f.first_paid_month) as cohort_quarter,
        datediff('month', f.first_paid_month, c.month_start_date) as months_since_start,
        c.is_paying
    from customer_mrr c
    inner join first_paid_month f
        on c.customer_id = f.customer_id
    where c.month_start_date >= f.first_paid_month
),

final as (
    select
        cohort_quarter,
        months_since_start,
        count(*) as customers_observed,
        count_if(is_paying) as customers_paying,
        count_if(is_paying) / count(*) as customer_retention_rate
    from cohort_activity
    group by 1, 2
)

select * from final