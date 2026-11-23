select
    customer_id,
    month_start_date,
    count(*) as row_count
from {{ ref('int_customer_mrr_monthly') }}
group by 1, 2
having count(*) > 1