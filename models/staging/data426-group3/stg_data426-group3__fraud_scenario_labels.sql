with source as (
    select * 
    from {{ source('data426-group3', 'fraud_scenario_labels') }}
),
renamed as (
    select
        cast(transaction_id as string) as transaction_id,
        coalesce(lower(trim(fraud_scenario)), 'unknown') as fraud_scenario,
        coalesce(lower(trim(scenario_group)), 'unknown') as scenario_group,
        cast(coalesce(is_original_fraud_label, 0) as int64) as is_original_fraud_label,
        cast(coalesce(is_engineered_scenario, 0) as int64) as is_engineered_scenario
    from source
)
select *
from renamed