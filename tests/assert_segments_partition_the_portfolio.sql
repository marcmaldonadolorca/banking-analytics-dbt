-- Each segmentation must split the whole portfolio exactly once: within every segment_type,
-- customers and defaults add up to the portfolio totals (no client lost or double counted).
with portfolio as (

    select customers, defaults
    from {{ ref('default_rate_by_segment') }}
    where segment_type = 'portfolio'

),

by_type as (

    select segment_type, sum(customers) as customers, sum(defaults) as defaults
    from {{ ref('default_rate_by_segment') }}
    group by segment_type

)

select by_type.*
from by_type
cross join portfolio
where by_type.customers != portfolio.customers
    or by_type.defaults != portfolio.defaults
    or portfolio.customers != (select count(*) from {{ ref('dim_customer') }})
