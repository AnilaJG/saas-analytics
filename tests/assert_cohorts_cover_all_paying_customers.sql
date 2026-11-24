-- The number of customers across all cohorts must equal the number of customers who ever paid

with cohorts as (
    select sum(customers_observed) as cohort_total
    from {{ ref('rpt_cohort_retention') }}
    where months_since_start = 0
),

paying as (
    select count(distinct customer_id) as paying_total
    from {{ ref('fct_mrr_monthly') }}
    where is_paying = true
)

select *
from cohorts
cross join paying
where cohort_total != paying_total