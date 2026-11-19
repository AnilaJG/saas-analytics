with source as (
    select * from {{ ref('invoices') }}
),

renamed as (
    select
        invoice_id,
        subscription_id,
        customer_id,
        amount_due::number(10, 2) as amount_due,
        amount_paid::number(10, 2) as amount_paid,
        lower(status) as invoice_status,
        invoice_date::date as invoice_date,
        due_date::date as due_date
    from source
)

select * from renamed