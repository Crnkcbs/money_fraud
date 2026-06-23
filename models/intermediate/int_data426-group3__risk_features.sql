-- int_data426-group3__risk_features.sql
SELECT 
    transaction_id,
    risk_score_rule_based,
    risk_level,
    risk_reason_count,
    high_amount_flag,
    high_velocity_flag,
    new_receiver_flag,
    many_to_one_receiver_flag,
    suspicious_cashout_flag,
    large_transfer_flag
FROM {{ref("stg_data426-group3__risk_features")}}