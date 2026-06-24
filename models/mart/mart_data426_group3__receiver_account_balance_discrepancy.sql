-- mart_data426-group3__receiver_account_balance_discrepancy.sql
SELECT 
    tf.transaction_id,
    tf.type,
    tf.is_fraud,
    tf.is_flagged_fraud,
    tf.step,
    tf.nameorig,
    tf.amount,
    tf.old_balance_dest,
    tf.new_balance_dest,
    b.leakage_warning,
    b.is_sender_balance_zero_after,
    b.is_dest_balance_zero_before
FROM {{ ref('int_data426-group3__transactions_join_fraud_scenario') }} AS tf
JOIN {{ ref('int_data426-group3__balance_features') }} AS b  ON b.transaction_id = tf.transaction_id
WHERE (tf.old_balance_dest + tf.amount != tf.new_balance_dest) AND tf.is_merchant_dest = 0