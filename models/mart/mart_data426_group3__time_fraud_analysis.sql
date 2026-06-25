{{ config(
    materialized = 'table'
) }}

WITH base AS (
    SELECT
        transaction_id,
        hour,
        day,
        period_of_day,
        is_night,
        is_first_week,
        is_first_half_month,
        sender_tx_count_1h,
        sender_tx_count_24h,
        sender_total_amount_24h,
        sender_avg_amount_24h,
        sender_unique_receivers_24h,
        amount_to_sender_avg_ratio,
        amount,
        type,
        is_fraud

    FROM {{ ref('int_data426-group3__temporal_senderbehavior_transactions') }}
),

aggregated AS (
    SELECT
        hour,
        period_of_day,
--KPIlar
        -- toplam işlem sayısı
        COUNT(*) AS txn_count,

        -- fraud sayısı
        SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) AS fraud_count,
        
        --fraud rate
        SAFE_DIVIDE(
            SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END),
            COUNT(*)
        ) AS fraud_rate,

        -- amount metrikleri
        AVG(amount) AS avg_amount,
        MAX(amount) AS max_amount,

        -- kişinin normale göre çok yüksek işlem sayısı
        SUM(
            CASE 
                WHEN amount > sender_avg_amount_24h * 2 THEN 1 
                ELSE 0 
            END
        ) AS spike_txn_count

    FROM base
    GROUP BY hour, period_of_day
)

SELECT *
FROM aggregated
ORDER BY hour
