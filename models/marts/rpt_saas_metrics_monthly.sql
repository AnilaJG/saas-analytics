with customer_mrr as (
    select * from {{ ref('fct_mrr_monthly') }}
),

monthly_totals as (
    select
        month_start_date,
        sum(mrr) as mrr,
        sum(previous_mrr) as starting_mrr,
        sum(new_mrr) as new_mrr,
        sum(reactivation_mrr) as reactivation_mrr,
        sum(expansion_mrr) as expansion_mrr,
        sum(contraction_mrr) as contraction_mrr,
        sum(churned_mrr) as churned_mrr,
        count_if(is_paying) as paying_customers,
        count_if(previous_mrr > 0) as starting_customers,
        count_if(churned_mrr > 0) as churned_customers
    from customer_mrr
    group by 1
),

final as (
    select
        month_start_date,
        mrr,
        mrr * 12 as arr,
        paying_customers,
        mrr / nullif(paying_customers, 0) as arpa,
        new_mrr,
        reactivation_mrr,
        expansion_mrr,
        contraction_mrr,
        churned_mrr,
        new_mrr + reactivation_mrr + expansion_mrr - contraction_mrr - churned_mrr as net_new_mrr,
        (starting_mrr - contraction_mrr - churned_mrr) / nullif(starting_mrr, 0) as gross_revenue_retention,
        (starting_mrr + expansion_mrr - contraction_mrr - churned_mrr) / nullif(starting_mrr, 0) as net_revenue_retention,
        churned_customers / nullif(starting_customers, 0) as logo_churn_rate
    from monthly_totals
)

select * from final