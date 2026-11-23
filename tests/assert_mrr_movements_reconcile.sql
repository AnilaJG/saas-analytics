select *
from {{ ref('int_customer_mrr_monthly') }}
where mrr != previous_mrr + new_mrr + reactivation_mrr + expansion_mrr - contraction_mrr - churned_mrr