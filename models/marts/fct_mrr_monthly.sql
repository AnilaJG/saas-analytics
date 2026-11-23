with customer_mrr as (
    select * from {{ ref('int_customer_mrr_monthly') }}
),

final as (
    select
        customer_id,
        month_start_date,
        month_end_date,
        mrr,
        previous_mrr,
        new_mrr,
        reactivation_mrr,
        expansion_mrr,
        contraction_mrr,
        churned_mrr,
        mrr > 0 as is_paying
    from customer_mrr
)

select * from final