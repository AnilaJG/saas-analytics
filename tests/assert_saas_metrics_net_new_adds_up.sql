-- Adding up every month's net new MRR must equal the latest month's MRR

with totals as (
    select sum(net_new_mrr) as total_net_new_mrr
    from {{ ref('rpt_saas_metrics_monthly') }}
),

latest as (
    select mrr as latest_mrr
    from {{ ref('rpt_saas_metrics_monthly') }}
    where month_start_date = date_trunc('month', to_date('{{ var("as_of_date") }}'))
)

select *
from totals
cross join latest
where total_net_new_mrr != latest_mrr