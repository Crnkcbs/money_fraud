with 

source as (
    -- Temizlenmiş staging modelini  çağırıyoruz
    select * from {{ ref('stg_data426-group3__sender_receiver_features') }}
),

final as (
    select
        transaction_id,
        nameorig,
        namedest,
        same_receiver_count_24h,
        sender_receiver_tx_count_so_far,
        is_new_receiver_for_sender
    from source
)

select * from final