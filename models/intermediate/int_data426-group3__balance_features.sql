with 

source as (
    -- Staging modelini güvenli bir şekilde çağırıyoruz
    select * from {{ ref('stg_data426-group3__balance_features') }}
),

final as (
    select
        transaction_id,
        balance_diff_orig,
        balance_diff_dest,
        expected_newbalance_orig, 
        expected_newbalance_dest,
        orig_balance_error,
        dest_balance_error,
        is_sender_balance_zero_after,
        is_dest_balance_zero_before,
        is_dest_balance_missing,
        leakage_warning
    from source
)

select * from final