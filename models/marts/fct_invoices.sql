with invoice_payments as (
    select * from {{ ref('int_invoice_payments') }}
),

final as (
    select
        invoice_id,
        subscription_id,
        customer_id,
        company_name,
        plan_tier,
        invoice_date,
        due_date,
        amount_due,
        amount_paid,
        unpaid_balance,
        payment_status
    from invoice_payments
)

select * from final