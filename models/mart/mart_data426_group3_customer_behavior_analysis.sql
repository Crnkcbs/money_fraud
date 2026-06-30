WITH main_transactions AS (
    SELECT *,

-- Python kısmına hazırlık: İşlem türüne sayısal kimlik verilmek için type_code sütunu eklendi.
    CASE
        WHEN type = 'TRANSFER' THEN 1
        WHEN type = 'CASH_OUT' THEN 2
        WHEN type = 'CASH_IN'  THEN 3
        WHEN type = 'DEBIT'    THEN 4
        WHEN type = 'PAYMENT'  THEN 5
    END AS type_code,    

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

-- scenario_group sütunu Python kısmına hazırlık: İşlem türüne sayısal kimlik verilmek için scenario_group_code sütunu eklendi.  

    CASE
        WHEN scenario_group = 'normal'                        THEN 0
        WHEN scenario_group = 'original_fraud'                THEN 1
        WHEN scenario_group = 'engineered_suspicious_pattern' THEN 2
    END AS scenario_group_code,

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

FROM {{ ref('int_data426-group3__transactions_join_fraud_scenario') }} 
),

temporal_sender_data AS (
    SELECT * FROM {{ ref('int_data426-group3__temporal_join_sender_behavior_features') }}
),

risk_flag_data AS (
    SELECT * FROM {{ ref('int_data426-group3__network_join_risk_features') }}
),

sender_receiver_data AS (
    SELECT * FROM {{ ref('int_data426-group3__sender_receiver_features') }}
),    

joined_data AS (
    SELECT 
        t.*, 
        ts.day,
        ts.is_night,
        src.is_new_receiver_for_sender,
        risk.risk_level,
        risk.high_amount_flag,
        risk.high_velocity_flag,
        risk.new_receiver_flag,
        risk.many_to_one_receiver_flag,
        CAST(FLOOR((ts.day - 1) / 30) + 1 AS INT64) AS custom_month_id
        
    FROM main_transactions t
    INNER JOIN temporal_sender_data ts ON t.transaction_id = ts.transaction_id
    INNER JOIN risk_flag_data risk ON t.transaction_id = risk.transaction_id
    INNER JOIN sender_receiver_data src ON t.transaction_id = src.transaction_id
),

calculated_volumes AS (
    SELECT
        *,
        SUM(CASE WHEN type = 'TRANSFER' THEN amount ELSE 0 END) OVER(
            PARTITION BY nameorig, custom_month_id
        ) AS monthly_transfer_volume
    FROM joined_data
),

enriched_features AS (
    SELECT
        *,
        CASE 
            WHEN Safe_Cast(old_balance_orig AS STRING) IN ('true', 'false', 'TRUE', 'FALSE') THEN 0
            WHEN CAST(old_balance_orig AS FLOAT64) > 0 AND CAST(amount AS FLOAT64) = CAST(old_balance_orig AS FLOAT64) THEN 1 
            ELSE 0 
        END AS is_liquidation,

        COALESCE(ROUND(CAST(amount AS FLOAT64) / NULLIF(monthly_transfer_volume, 0), 4), 0.0) AS amount_to_monthly_volume_ratio
    FROM calculated_volumes
),

scoring_layer AS (
    SELECT
        *,
        (
            (CASE WHEN CAST(is_liquidation AS INT64) = 1 THEN 20 ELSE 0 END) +
            (CASE WHEN CAST(many_to_one_receiver_flag AS INT64) = 1 THEN 15 ELSE 0 END) +
            (CASE WHEN CAST(is_new_receiver_for_sender AS INT64) = 1 THEN 10 ELSE 0 END) +
            (CASE WHEN CAST(new_receiver_flag AS INT64) = 1 THEN 5 ELSE 0 END) +
            (CASE WHEN amount_to_monthly_volume_ratio > 1.0 THEN 15 ELSE 0 END) +
            (CASE WHEN CAST(high_amount_flag AS INT64) = 1 THEN 10 ELSE 0 END) +
            (CASE WHEN CAST(high_velocity_flag AS INT64) = 1 THEN 15 ELSE 0 END) +
            (CASE WHEN CAST(is_night AS INT64) = 1 THEN 5 ELSE 0 END) +
            (CASE WHEN type IN ('TRANSFER', 'CASH_OUT') THEN 5 ELSE 0 END)
        ) AS calculated_risk_score
    FROM enriched_features
)

SELECT
    *,
    CASE 
        WHEN calculated_risk_score >= 50 THEN 'Çok Yüksek Risk - Blokaj / Alarm'
        WHEN calculated_risk_score >= 25 THEN 'Yüksek Risk - Manuel İnceleme'
        WHEN calculated_risk_score >= 15 THEN 'Orta Risk - Ek SMS Onayı'
        ELSE 'Düşük Risk - Güvenli İşlem'
    END AS risk_segment
FROM scoring_layer




--Kategoriler ve Benzersiz Sütunlar	-Puanlama Koşulu	-Net Ağırlık Puanı--

---1. Hesap Boşaltma (Likidasyon) Anomalisi--
--is_liquidation	old_balance_orig > 0 AND amount = old_balance_orig:20 Puan 

---2. Grafik & Ağ Analitiği (Havuz Hesap Tespiti)--		
--many_to_one_receiver_flag	(Kısa sürede çok kişiden tek alıcıya akış varsa) ben :15 Puan
--is_new_receiver_for_sender	(Gönderen bu alıcıya ilk defa para gönderiyorsa):10 Puan
--new_receiver_flag	Alıcı hesap sistemde çok yeni açılmışsa:5 Puan

--3. Miktar ve Hacim Anomalileri--

--amount_to_monthly_volume_ratio	(Anlık işlem aylık transfer hacminin üzerindeyse (> 1.0)):15 Puan
---high_amount_flag	İşlem tutarı normalin çok üzerindeyse:10 Puan 

--4. Hız ve Davranış Faktörleri	--	

--suspicious_cashout_flag	(Paranın hızlıca nakde/kriptoya dönüştürülme şüphesi):10 Puan
--high_velocity_flag	(İşlem sıklığı/hızı şüpheli derecede yüksekse):5 Puan
--is_night	İşlem gece saatlerinde yapıldıysa:5 Puan
--type / type_code	İşlem türü TRANSFER veya CASH_OUT ise:5 Puan

---TOPLAM MAKSİMUM PUAN	:Tüm Benzersiz Kırmızı Bayraklar Tetiklendiğinde :100 Puan--