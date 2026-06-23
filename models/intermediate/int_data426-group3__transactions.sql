with 

source as (
    -- Staging modelini  çağırıyoruz.
    select * from {{ ref('stg_data426-group3__transactions') }}
),

final as (
    select
        transaction_id,
        step,
        type,
        nameorig,
        amount,
        old_balance_orig,
        new_balance_orig,
        namedest,
        old_balance_dest,
        new_balance_dest,
        is_fraud,
        is_flagged_fraud,
        is_merchant_dest,
        is_customer_dest
    from source
)

select * from final