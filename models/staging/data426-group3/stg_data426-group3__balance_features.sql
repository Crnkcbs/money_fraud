with 

source as (

    select * from {{ source('data426-group3', 'balance_features') }}

),

renamed as (

    select
        transaction_id,
--virgülden sonra 2 basamağa yuvarlanan finanasal alanlar--
        round(cast(balance_diff_orig as float64),2) as balance_diff_orig,
        round(cast(balance_diff_dest as float64),2) as balance_diff_dest,
        round(cast(expected_newbalanceOrig as float64),2) as expected_newbalance_orig,
        round(cast(expected_newbalanceDest as float64),2) as expected_newbalance_dest,

-- Hassas hata payları (yuvarlamadan,sadece float64 yapıyoruz)--   
        cast(orig_balance_error as float64) as orig_balance_error,
        cast(dest_balance_error as float64) as dest_balance_error,

--
        cast(is_sender_balance_zero_after as integer) as is_sender_balance_zero_after,
        cast(is_dest_balance_zero_before as integer) as is_dest_balance_zero_before,
        cast(is_dest_balance_missing as integer) as is_dest_balance_missing,
        leakage_warning

    from source

)

select * from renamed