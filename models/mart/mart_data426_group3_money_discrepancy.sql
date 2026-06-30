-- mart_data426-group3__money_discrepancy.sql

WITH transactions AS (
    SELECT * 
    FROM {{ ref('int_data426-group3__transactions_join_fraud_scenario') }}
),

balance_features AS (
    SELECT * 
    FROM {{ ref('int_data426-group3__balance_features') }}
)

SELECT 
    tf.transaction_id,
    tf.type,
    tf.is_fraud,
    tf.is_flagged_fraud,
    tf.step,
    tf.nameorig,
    tf.amount,
    tf.old_balance_orig,
    tf.new_balance_orig,
    (tf.old_balance_orig - tf.amount - tf.new_balance_orig) AS sender_discrepancy,
    tf.old_balance_dest,
    tf.new_balance_dest,
    tf.is_merchant_dest,
    (tf.old_balance_dest + tf.amount - tf.new_balance_dest) AS receiver_discrepancy,
    b.leakage_warning,
    b.is_sender_balance_zero_after,
    b.is_dest_balance_zero_before
FROM transactions AS tf
INNER JOIN balance_features AS b 
    ON tf.transaction_id = b.transaction_id