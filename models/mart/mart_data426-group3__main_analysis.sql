
SELECT
    transaction_id,
    step,
    amount,
    type,
-- Python kısmına hazırlık: İşlem türüne sayısal kimlik verilmek için type_code sütunu eklendi.
    CASE
        WHEN type = 'TRANSFER' THEN 1
        WHEN type = 'CASH_OUT' THEN 2
        WHEN type = 'CASH_IN'  THEN 3
        WHEN type = 'DEBIT'    THEN 4
        WHEN type = 'PAYMENT'  THEN 5
    END AS type_code,
    
    old_balance_orig,
    new_balance_orig,

-- Python'da modelin "hesap sıfırlandı mı" mantığını doğrudan okuyabilmesi için 'is_account_emptied' sütunu ekliyoruz.
    CASE
        WHEN new_balance_orig = 0 AND old_balance_orig > 0 THEN 1
        ELSE 0
    END AS is_account_emptied,
    
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