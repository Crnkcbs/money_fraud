-- int_data426-group3__transactions_fraud_scenario_labels_joint.sql
SELECT 
    *
FROM {{ref("stg_data426-group3__transactions")}} as t
JOIN {{ref("stg_data426-group3__fraud_scenario_labels")}} as f USING transaction_id