SELECT
    transaction_id,
    type,
    step,
    amount,

-- Python kısmına hazırlık işlem türüne sayısal kimlik verilmek için type_code sütunu eklendi.
CASE 
    WHEN type = 'TRANSFER' THEN 1 
    WHEN type = 'CASH_OUT' THEN 2 
    WHEN type = 'CASH_IN' THEN 3
    WHEN type = 'DEBIT'   THEN 4
    WHEN type = 'PAYMENT' THEN 5
END AS type_code,

    old_balance_orig,
    new_balance_orig,

-- Pyton'da modelin "hesap sıfırlandı mı" mantığını doğrudan okuyabilmesi için 'is_account_emptied' (YENİ SÜTUN - Boolean/Flag) sütunu ekliyoruz.
CASE    
    WHEN new_balance_orig = 0 
    AND old_balance_orig > 0 THEN 1 
    ELSE 0 
END AS is_account_emptied, 
     
     old_balance_dest,
     new_balance_dest,

-- Python'da modelin 'is_fraud' sütununa sayısal kimlik verilmek için 'is_fraud_type' sütunu oluşturuldu.
CASE
    WHEN is_fraud = 'FALSE' THEN 0
         


    


