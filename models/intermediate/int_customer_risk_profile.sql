with statements as (

    select * from {{ ref('int_card_statements_unpivoted') }}

),

latest_month as (

    select max(statement_month) as statement_month from statements

),

profile as (

    select
        statements.customer_id,
        count(*) as statement_count,
        max(statements.statement_month) as last_statement_month,
        max(statements.months_past_due) as worst_months_past_due_6m,
        sum(case when statements.months_past_due >= 1 then 1 else 0 end) as months_delinquent_6m,
        avg(statements.utilization_ratio) as avg_utilization_ratio_6m,
        sum(statements.payment_amount_ntd) as total_payments_6m_ntd,
        max(case
            when statements.statement_month = latest_month.statement_month
                then statements.repayment_status_code
        end) as latest_repayment_status_code
    from statements
    cross join latest_month
    group by statements.customer_id

)

select
    *,
    case
        when worst_months_past_due_6m = 0 then 'never_delinquent'
        when worst_months_past_due_6m = 1 then 'max_30_dpd'
        when worst_months_past_due_6m = 2 then 'max_60_dpd'
        else 'max_90_plus_dpd'
    end as worst_delinquency_6m
from profile
