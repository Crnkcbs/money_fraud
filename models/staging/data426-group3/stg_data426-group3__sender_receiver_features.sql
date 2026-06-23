with 

source as (

    select * from {{ source('data426-group3', 'sender_receiver_features') }}

),

renamed as (

    select
        transaction_id,
        nameorig,
        namedest,
-- Sayım (Count) bildiren alanları tam sayı (int64) yapıyoruz        
        cast(same_receiver_count_24h as int64) as same_receiver_count_24h,
        cast(sender_receiver_tx_count_so_far as int64) as sender_receiver_tx_count_so_far,
-- Durum (Flag) bildiren alanı true/false (boolean) yapıyoruz        
        cast(is_new_receiver_for_sender as boolean) as is_new_receiver_for_sender

    from source

)

select * from renamed