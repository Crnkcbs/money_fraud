-- int_data426-group3__network_risk_features.sql

WITH network_features AS (
    SELECT 
        n.transaction_id,
        n.nameorig,
        n.namedest,
        n.sender_out_degree_so_far,
        n.receiver_in_degree_so_far,
        n.receiver_tx_count_so_far,
        n.receiver_received_amount_so_far,
        n.sender_receiver_network_count_so_far
    FROM {{ ref("stg_data426-group3__network_features") }} AS n
),

risk_features AS ( 
    SELECT 
        r.transaction_id,
        r.risk_score_rule_based,
        r.risk_level,
        r.risk_reason_count,
        r.high_amount_flag,
        r.high_velocity_flag,
        r.new_receiver_flag,
        r.many_to_one_receiver_flag,
        r.suspicious_cashout_flag,
        r.large_transfer_flag        
    FROM {{ ref("stg_data426-group3__risk_features") }} AS r
)

-- iki tablonun tüm sütunlarını join etme
SELECT
    -- Network tablosundaki tüm sütunlar
    n.*,
    
    -- Risk tablosundaki (transaction_id hariç) tüm sütunlar
    r.risk_score_rule_based,
    r.risk_level,
    r.risk_reason_count,
    r.high_amount_flag,
    r.high_velocity_flag,
    r.new_receiver_flag,
    r.many_to_one_receiver_flag,
    r.suspicious_cashout_flag,
    r.large_transfer_flag
         
FROM network_features AS n    
LEFT JOIN risk_features AS r 
    ON n.transaction_id = r.transaction_id