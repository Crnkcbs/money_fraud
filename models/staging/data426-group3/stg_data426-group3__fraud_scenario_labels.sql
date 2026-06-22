with 

source as (

    select * from {{ source('data426-group3', 'fraud_scenario_labels') }}

),

renamed as (

    select
        transaction_id,
        fraud_scenario,
        scenario_group,
        is_original_fraud_label,
        is_engineered_scenario

    from source

)

select * from renamed