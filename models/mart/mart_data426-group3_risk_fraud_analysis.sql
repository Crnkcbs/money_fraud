-- mart_data426-group3_risk_fraud_analysis.sql
SELECT 
    tf.transaction_id,
    tf.type,
    tf.is_fraud,
    tf.is_flagged_fraud,
    r.risk_score_rule_based,
    r.risk_level,
    r.risk_reason_count,
    r.high_velocity_flag,
    r.new_receiver_flag,
    r.many_to_one_receiver_flag,
    r.suspicious_cashout_flag,
    r.large_transfer_flag
FROM {{ ref('int_data426-group3__transactions_join_fraud_scenario') }} AS tf
JOIN {{ ref('stg_data426-group3__risk_features') }} AS r ON r.transaction_id = tf.transaction_id