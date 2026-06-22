with 

source as (

    select * from {{ source('data426-group3', 'transactions') }}

),

renamed as (

    select
        transaction_id,
        step,
        type,
        amount,
        nameorig,
        oldbalanceorg,
        newbalanceorig,
        namedest,
        oldbalancedest,
        newbalancedest,
        isfraud,
        isflaggedfraud,
        is_merchant_dest,
        is_customer_dest

    from source

)

select * from renamed