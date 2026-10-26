{%- set segment_columns = ['worst_delinquency_6m', 'credit_limit_band', 'age_band', 'education_level'] -%}

with outcomes as (

    select
        fct_default_outcomes.defaulted_flag,
        fct_default_outcomes.worst_delinquency_6m,
        dim_customer.credit_limit_band,
        dim_customer.age_band,
        dim_customer.education_level
    from {{ ref('fct_default_outcomes') }} as fct_default_outcomes
    inner join {{ ref('dim_customer') }} as dim_customer
        on fct_default_outcomes.customer_id = dim_customer.customer_id

),

segments as (

    select
        'portfolio' as segment_type,
        'all' as segment_value,
        count(*) as customers,
        sum(defaulted_flag) as defaults
    from outcomes

    {% for column in segment_columns %}
    union all

    select
        '{{ column }}' as segment_type,
        {{ column }} as segment_value,
        count(*) as customers,
        sum(defaulted_flag) as defaults
    from outcomes
    group by {{ column }}
    {% endfor %}

)

select
    segment_type,
    segment_value,
    customers,
    defaults,
    defaults / customers as default_rate
from segments
