with 

source as (

    select * from {{ source('data426-group3', 'sender_receiver_features') }}

),

renamed as (

    select
        transaction_id,
        nameorig,
        namedest,
        same_receiver_count_24h,
        sender_receiver_tx_count_so_far,
        is_new_receiver_for_sender

    from source

)

select * from renamed