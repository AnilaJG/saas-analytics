with source as (
    select * from {{ ref('customers') }}
),

renamed as (
    select
        customer_id,
        company_name,
        signup_date,
        plan_tier
    from source
)

select * from renamed