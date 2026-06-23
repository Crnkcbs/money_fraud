-- int_data426-group3__temporal_sender_behavior.sql

WITH sender_behavior AS (
    SELECT 
        s.transaction_id,
        s.nameorig,
        s.sender_tx_count_1h,
        s.sender_tx_count_total_so_far,
        s.sender_tx_count_24h, 
        s.sender_total_amount_24h, 
        s.sender_avg_amount_24h, 
        s.amount_to_sender_avg_ratio, 
        s.sender_unique_receivers_24h
    FROM {{ ref("stg_data426-group3__sender_behavior_features") }} AS s
),

temporal AS ( 
    SELECT 
        t.transaction_id, 
        t.day,
        t.hour,
        t.period_of_day,
        t.is_night,
        t.is_first_week,
        t.is_first_half_month               
    FROM {{ ref("stg_data426-group3__temporal_features") }} AS t
)

-- iki tablonun tüm sütunlarını join etme
SELECT
    -- sender_behavior tablosundaki tüm sütunlar
    s.*, 
    
    -- temporal tablosundaki (transaction_id hariç) tüm sütunlar
    t.day,
    t.hour,
    t.period_of_day,
    t.is_night,
    t.is_first_week,
    t.is_first_half_month
         
FROM sender_behavior AS s    
LEFT JOIN temporal AS t 
    ON s.transaction_id = t.transaction_id