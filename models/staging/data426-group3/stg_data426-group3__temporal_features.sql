with 

source as (

    select * from {{ source('data426-group3', 'temporal_features') }}

),

renamed as (

    select
        transaction_id,
        day,
        hour,
        period_of_day,
        is_night,
        is_first_week,
        is_first_half_month

    from source

)

select * from renamed