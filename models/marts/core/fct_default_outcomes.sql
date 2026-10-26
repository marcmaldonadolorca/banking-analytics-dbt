with clients as (

    select * from {{ ref('stg_uci__credit_card_clients') }}

),

risk_profile as (

    select * from {{ ref('int_customer_risk_profile') }}

)

select
    clients.customer_id,
    -- The outcome is observed on the payment due the month after the last statement.
    cast({{ dbt.dateadd('month', 1, 'risk_profile.last_statement_month') }} as date) as outcome_month,
    case when clients.defaulted_next_month then 1 else 0 end as defaulted_flag,
    risk_profile.statement_count,
    risk_profile.latest_repayment_status_code,
    risk_profile.worst_months_past_due_6m,
    risk_profile.worst_delinquency_6m,
    risk_profile.months_delinquent_6m,
    risk_profile.avg_utilization_ratio_6m,
    risk_profile.total_payments_6m_ntd
from clients
inner join risk_profile
    on clients.customer_id = risk_profile.customer_id
