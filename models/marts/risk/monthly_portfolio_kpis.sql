with statements as (

    select * from {{ ref('fct_card_statements') }}

)

select
    statement_month,
    count(*) as accounts,
    sum(case when bill_amount_ntd > 0 then 1 else 0 end) as accounts_with_balance,
    sum(bill_amount_ntd) as total_balance_ntd,
    avg(bill_amount_ntd) as avg_balance_ntd,
    avg(utilization_ratio) as avg_utilization_ratio,
    -- Share of last month's (positive) balance that was paid this month.
    sum(case when previous_bill_amount_ntd > 0 then payment_amount_ntd end)
        / nullif(sum(case when previous_bill_amount_ntd > 0 then previous_bill_amount_ntd end), 0)
        as payment_rate,
    sum(delinquent_30p_flag) as delinquent_30p_accounts,
    sum(delinquent_60p_flag) as delinquent_60p_accounts,
    sum(delinquent_90p_flag) as delinquent_90p_accounts,
    sum(delinquent_30p_flag) / count(*) as delinquency_rate_30p,
    sum(delinquent_60p_flag) / count(*) as delinquency_rate_60p,
    sum(delinquent_90p_flag) / count(*) as delinquency_rate_90p
from statements
group by statement_month
