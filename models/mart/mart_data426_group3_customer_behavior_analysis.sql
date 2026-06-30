WITH main_transactions AS (
    SELECT * FROM {{ ref('int_data426-group3__transactions_join_fraud_scenario') }}
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

        ROUND(amount / NULLIF(monthly_transfer_volume, 0), 4) AS amount_to_monthly_volume_ratio
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