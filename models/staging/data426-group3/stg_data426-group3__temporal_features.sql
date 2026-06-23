with source as (

    select *
    from {{ source('data426-group3', 'temporal_features') }}

),

renamed as (

    select
        cast(transaction_id as string) as transaction_id,

        cast(day as int64) as day,
        cast(hour as int64) as hour,

        coalesce(lower(trim(period_of_day)), 'unknown') as period_of_day,

        cast(coalesce(is_night, 0) as int64) as is_night,
        cast(coalesce(is_first_week, 0) as int64) as is_first_week,
        cast(coalesce(is_first_half_month, 0) as int64) as is_first_half_month

    from source

),

cleaned as (

    select
        transaction_id,

        case
            when day between 1 and 31 then day
            else null
        end as day,

        case
            when hour between 0 and 23 then hour
            else null
        end as hour,

        case
            when period_of_day in ('morning', 'afternoon', 'evening', 'night')
                then period_of_day
            else 'unknown'
        end as period_of_day,

        case
            when is_night in (0, 1) then is_night
            else 0
        end as is_night,

        case
            when is_first_week in (0, 1) then is_first_week
            else 0
        end as is_first_week,

        case
            when is_first_half_month in (0, 1) then is_first_half_month
            else 0
        end as is_first_half_month

    from renamed

)

select *
from cleaned