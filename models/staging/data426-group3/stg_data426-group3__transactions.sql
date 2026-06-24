with 

source as (

    select * from {{ source('data426-group3', 'transactions') }}

),

renamed as (

    select
        transaction_id,
        step,
        type,
        nameOrig as nameorig,
----virgülden sonra 2 basamağa yuvarlanan finanasal alanlar--

        round(cast(amount as float64),2) as amount,
        round(cast(oldbalanceOrg as float64),2) as old_balance_orig,
        round(cast(newbalanceOrig as float64),2) as new_balance_orig,
        nameDest as namedest,
        round(cast(oldbalanceDest as float64),2) as old_balance_dest,
        round(cast(newbalanceDest as float64),2) as new_balance_dest,
--               
        cast(isfraud as integer) as is_fraud,
        cast(isFlaggedFraud as integer) as is_flagged_fraud,
        cast(is_merchant_dest as integer) as is_merchant_dest,
        cast(is_customer_dest as integer) as is_customer_dest

    from source

)

select * from renamed