
SELECT
    transaction_id,
    step,
    type,
-- Python kısmına hazırlık: İşlem türüne sayısal kimlik verilmek için type_code sütunu eklendi.
    CASE
        WHEN type = 'TRANSFER' THEN 1
        WHEN type = 'CASH_OUT' THEN 2
        WHEN type = 'CASH_IN'  THEN 3
        WHEN type = 'DEBIT'    THEN 4
        WHEN type = 'PAYMENT'  THEN 5
    END AS type_code,    

    amount,
      -- amount bucket
    CASE
        WHEN amount = 0 THEN '0'
        WHEN amount > 0 AND amount <= 100 THEN '0-100'
        WHEN amount <= 1000 THEN '100-1K'
        WHEN amount <= 10000 THEN '1K-10K'
        WHEN amount <= 50000 THEN '10K-50K'
        WHEN amount <= 100000 THEN '50K-100K'
        WHEN amount <= 500000 THEN '100K-500K'
        WHEN amount <= 1000000 THEN '500K-1M'
        ELSE '1M+'
    END AS amount_bucket,

    
    old_balance_orig,
    new_balance_orig,
    old_balance_dest,
    new_balance_dest,
    is_fraud,
    is_flagged_fraud,
    is_merchant_dest,
    is_customer_dest,
    scenario_group,
    
-- scenario_group sütunu Python kısmına hazırlık: İşlem türüne sayısal kimlik verilmek için scenario_group_code sütunu eklendi.  

    CASE
        WHEN scenario_group = 'normal'                        THEN 0
        WHEN scenario_group = 'original_fraud'                THEN 1
        WHEN scenario_group = 'engineered_suspicious_pattern' THEN 2
    END AS scenario_group_code,

    fraud_scenario,

-- fraud_scenario sütunu Python kısmına hazırlık: İşlem türüne sayısal kimlik verilmek için fraud_scenario_code sütunu eklendi.      
   
    CASE
        WHEN fraud_scenario = 'normal'                   THEN 0
        WHEN fraud_scenario = 'original_fraud_transfer'  THEN 1
        WHEN fraud_scenario = 'original_fraud_cashout'   THEN 2
        WHEN fraud_scenario = 'suspicious_cashout'       THEN 3
        WHEN fraud_scenario = 'new_receiver_high_amount' THEN 4
        WHEN fraud_scenario = 'many_to_one_receiver'     THEN 5
        WHEN fraud_scenario = 'large_transfer'           THEN 6
    END AS fraud_scenario_code,

        is_original_fraud_label,
        is_engineered_scenario
    

FROM {{ ref('int_data426-group3__transactions_join_fraud_scenario') }} 
ORDER BY transaction_id