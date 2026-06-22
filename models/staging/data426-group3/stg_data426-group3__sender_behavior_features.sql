with 

source as (

    select * from {{ source('data426-group3', 'sender_behavior_features') }}

),

renamed as (

    select
        transaction_id,
        nameorig,
        sender_tx_count_total_so_far,
        sender_tx_count_1h,
        sender_tx_count_24h,
        sender_total_amount_24h,
        sender_avg_amount_24h,
        amount_to_sender_avg_ratio,
        sender_unique_receivers_24h

    from source

)

select * from renamed