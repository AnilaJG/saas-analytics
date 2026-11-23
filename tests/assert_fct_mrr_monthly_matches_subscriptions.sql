-- MRR in the mart must match MRR calculated straight from the subscriptions

with mart as (

    select sum(mrr) as mart_total
    from {{ ref('fct_mrr_monthly') }}
    where month_end_date = '{{ var("as_of_date") }}'

),

subscriptions as (

    select sum(mrr_amount) as subscriptions_total
    from {{ ref('stg_subscriptions') }}
    where start_date <= '{{ var("as_of_date") }}'
      and (end_date is null or end_date > '{{ var("as_of_date") }}')

)

select *
from mart
cross join subscriptions
where mart_total != subscriptions_total