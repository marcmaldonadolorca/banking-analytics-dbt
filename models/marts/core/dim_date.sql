with days as (

    -- Calendar for 2005: statements run April-September, the default outcome is October.
    {{ dbt.date_spine(
        datepart='day',
        start_date="cast('2005-01-01' as date)",
        end_date="cast('2006-01-01' as date)"
    ) }}

)

select
    cast(date_day as date) as date_day,
    extract(year from date_day) as year_number,
    extract(quarter from date_day) as quarter_number,
    extract(month from date_day) as month_number,
    extract(year from date_day) * 100 + extract(month from date_day) as year_month,
    cast({{ dbt.date_trunc('month', 'date_day') }} as date) as month_start_date,
    cast({{ dbt.last_day('date_day', 'month') }} as date) as month_end_date,
    extract(day from date_day) = 1 as is_month_start
from days
