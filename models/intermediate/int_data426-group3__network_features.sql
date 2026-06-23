-- int_data426-group3__network_features.sql
SELECT 
    transaction_id,
    nameorig as nameOrig,
    namedest as nameDest,
    sender_out_degree_so_far,
    receiver_in_degree_so_far,
    receiver_tx_count_so_far,
    receiver_received_amount_so_far,
    sender_receiver_network_count_so_far
FROM {{ref("stg_data426-group3__network_features")}}