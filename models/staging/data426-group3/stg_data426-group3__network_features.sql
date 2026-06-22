with 

source as (

    select * from {{ source('data426-group3', 'network_features') }}

),

renamed as (

    select
        transaction_id,
        nameorig,
        namedest,
        sender_out_degree_so_far,
        receiver_in_degree_so_far,
        receiver_tx_count_so_far,
        receiver_received_amount_so_far,
        sender_receiver_network_count_so_far

    from source

)

select * from renamed