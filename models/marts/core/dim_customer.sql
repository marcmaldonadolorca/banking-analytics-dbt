with clients as (

    select * from {{ ref('stg_uci__credit_card_clients') }}

),

education_levels as (

    select * from {{ ref('education_levels') }}

),

marital_statuses as (

    select * from {{ ref('marital_statuses') }}

)

select
    clients.customer_id,
    clients.sex,
    clients.age_years,
    case
        when clients.age_years < 30 then 'under_30'
        when clients.age_years < 40 then '30_39'
        when clients.age_years < 50 then '40_49'
        when clients.age_years < 60 then '50_59'
        else '60_plus'
    end as age_band,
    education_levels.education_level,
    marital_statuses.marital_status,
    clients.credit_limit_ntd,
    case
        when clients.credit_limit_ntd < 50000 then 'under_50k'
        when clients.credit_limit_ntd < 150000 then '50k_150k'
        when clients.credit_limit_ntd < 300000 then '150k_300k'
        else '300k_plus'
    end as credit_limit_band
from clients
left join education_levels
    on clients.education_code = education_levels.education_code
left join marital_statuses
    on clients.marital_status_code = marital_statuses.marital_status_code
