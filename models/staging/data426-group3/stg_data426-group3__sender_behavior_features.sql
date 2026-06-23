with source as (

    select *
    from {{ source('data426-group3', 'sender_behavior_features') }}

),

cleaned as (

    select
        cast(transaction_id as string) as transaction_id,
        coalesce(trim(nameOrig), 'unknown') as nameOrig,

        case
            when coalesce(sender_tx_count_total_so_far, 0) >= 0 
            then cast(sender_tx_count_total_so_far as int64)
            else 0
        end as sender_tx_count_total_so_far,

        case
            when coalesce(sender_tx_count_1h, 0) >= 0 
            then cast(sender_tx_count_1h as int64)
            else 0
        end as sender_tx_count_1h,

        case
            when coalesce(sender_tx_count_24h, 0) >= 0 
            then cast(sender_tx_count_24h as int64)
            else 0
        end as sender_tx_count_24h,

        case
            when coalesce(sender_total_amount_24h, 0) >= 0 
            then cast(sender_total_amount_24h as float64)
            else 0
        end as sender_total_amount_24h,

        case
            when coalesce(sender_avg_amount_24h, 0) >= 0 
            then cast(sender_avg_amount_24h as float64)
            else 0
        end as sender_avg_amount_24h,

        case
            when coalesce(amount_to_sender_avg_ratio, 0) >= 0 
            then cast(amount_to_sender_avg_ratio as float64)
            else 0
        end as amount_to_sender_avg_ratio,

        case
            when coalesce(sender_unique_receivers_24h, 0) >= 0 
            then cast(sender_unique_receivers_24h as int64)
            else 0
        end as sender_unique_receivers_24h

    from source

)

select *
from cleaned