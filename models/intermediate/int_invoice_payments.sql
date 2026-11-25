with invoices as (
    select * from {{ ref('stg_invoices') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

final as (
    select
        i.invoice_id,
        i.subscription_id,
        i.customer_id,
        c.company_name,
        c.plan_tier,
        i.amount_due,
        i.amount_paid,
        i.amount_due - i.amount_paid as unpaid_balance,
        case
            when i.amount_paid >= i.amount_due then 'paid'
            when i.amount_paid > 0 then 'partial'
            else 'unpaid'
        end as payment_status,
        i.invoice_date,
        i.due_date
    from invoices i
    left join customers c on i.customer_id = c.customer_id
)

select * from final