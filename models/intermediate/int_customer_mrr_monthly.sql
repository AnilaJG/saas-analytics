with customers as (
    select * from {{ ref('stg_customers') }}
),

subscriptions as (
    select * from {{ ref('stg_subscriptions') }}
),

bounds as (
    select
        date_trunc('month', min(signup_date)) as first_month,
        date_trunc('month', to_date('{{ var("as_of_date") }}')) as last_month
    from customers
),

months as (
    select
        dateadd(month, n.month_offset, b.first_month) as month_start_date,
        last_day(dateadd(month, n.month_offset, b.first_month)) as month_end_date
    from (
        select row_number() over (order by seq4()) - 1 as month_offset
        from table(generator(rowcount => 120))
    ) n
    cross join bounds b
    where dateadd(month, n.month_offset, b.first_month) <= b.last_month
),

first_paid as (
    select
        customer_id,
        date_trunc('month', min(start_date)) as first_paid_month
    from subscriptions
    group by 1
),

customer_months as (
    select
        f.customer_id,
        m.month_start_date,
        m.month_end_date
    from first_paid f
    inner join months m
        on m.month_start_date >= f.first_paid_month
),

monthly_mrr as (
    select
        cm.customer_id,
        cm.month_start_date,
        cm.month_end_date,
        coalesce(sum(s.mrr_amount), 0) as mrr
    from customer_months cm
    left join subscriptions s
        on s.customer_id = cm.customer_id
        and s.start_date <= cm.month_end_date
        and (s.end_date is null or s.end_date > cm.month_end_date)
    group by 1, 2, 3
),

with_previous as (
    select
        customer_id,
        month_start_date,
        month_end_date,
        mrr,
        coalesce(
            lag(mrr) over (partition by customer_id order by month_start_date),
            0
        ) as previous_mrr,
        coalesce(
            max(iff(mrr > 0, 1, 0)) over (
                partition by customer_id
                order by month_start_date
                rows between unbounded preceding and 1 preceding
            ),
            0
        ) as paid_before
    from monthly_mrr
),

final as (
    select
        customer_id,
        month_start_date,
        month_end_date,
        mrr,
        previous_mrr,
        case when previous_mrr = 0 and mrr > 0 and paid_before = 0
             then mrr else 0 end as new_mrr,
        case when previous_mrr = 0 and mrr > 0 and paid_before = 1
             then mrr else 0 end as reactivation_mrr,
        case when previous_mrr > 0 and mrr > previous_mrr
             then mrr - previous_mrr else 0 end as expansion_mrr,
        case when previous_mrr > 0 and mrr > 0 and mrr < previous_mrr
             then previous_mrr - mrr else 0 end as contraction_mrr,
        case when previous_mrr > 0 and mrr = 0
             then previous_mrr else 0 end as churned_mrr
    from with_previous
)

select * from final