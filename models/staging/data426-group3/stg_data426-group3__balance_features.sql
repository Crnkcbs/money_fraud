with 

source as (

    select * from {{ source('data426-group3', 'balance_features') }}

),

renamed as (

    select
        transaction_id,
        balance_diff_orig,
        balance_diff_dest,
        expected_newbalanceorig,
        expected_newbalancedest,
        orig_balance_error,
        dest_balance_error,
        is_sender_balance_zero_after,
        is_dest_balance_zero_before,
        is_dest_balance_missing,
        leakage_warning

    from source

)

select * from renamed