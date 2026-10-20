with source as (
    select * from {{ ref('invoices') }}
),

renamed as (
    select
        invoice_id,
        subscription_id,
        customer_id,
        amount_due,
        amount_paid,
        status,
        invoice_date,
        due_date
    from source
)

select * from renamed