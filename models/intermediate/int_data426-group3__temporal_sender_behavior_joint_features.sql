-- int_data426-group3__temporal_sender_behavior_joint_features.sql
SELECT 
    *
FROM {{ref("stg_data426-group3__temporal_features")}} as temp
JOIN {{ref("stg_data426-group3__sender_behavior_features")}} as sendb USING transaction_id