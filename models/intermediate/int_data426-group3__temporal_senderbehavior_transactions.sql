WITH sender_temporal AS (

    SELECT *
    FROM {{ ref('int_data426-group3__temporal_join_sender_behavior_features') }}

),

transactions AS (

    SELECT *
    FROM {{ ref('stg_data426-group3__transactions') }}

)

SELECT
    -- transaction tablosu 
    t.*,

    -- sender + temporal feature'lar
    st.sender_tx_count_1h,
    st.sender_tx_count_total_so_far,
    st.sender_tx_count_24h,
    st.sender_total_amount_24h,
    st.sender_avg_amount_24h,
    st.amount_to_sender_avg_ratio,
    st.sender_unique_receivers_24h,
    st.day,
    st.hour,
    st.period_of_day,
    st.is_night,
    st.is_first_week,
    st.is_first_half_month

FROM transactions t
LEFT JOIN sender_temporal st
    ON t.transaction_id = st.transaction_id
