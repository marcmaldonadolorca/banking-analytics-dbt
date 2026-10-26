{{
    config(
        materialized='incremental',
        unique_key=['customer_id', 'statement_month'],
        incremental_strategy='merge',
        on_schema_change='fail'
    )
}}

with statements as (

    select * from {{ ref('int_card_statements_unpivoted') }}

    {% if is_incremental() %}
    -- New statements arrive monthly. Re-merge the latest loaded month so late corrections to it
    -- are picked up; earlier months are treated as closed.
    where statement_month >= (select max(statement_month) from {{ this }})
    {% endif %}

)

select
    customer_id,
    statement_month,
    repayment_status_code,
    previous_repayment_status_code,
    credit_limit_ntd,
    bill_amount_ntd,
    previous_bill_amount_ntd,
    payment_amount_ntd,
    utilization_ratio,
    months_past_due,
    case when months_past_due >= 1 then 1 else 0 end as delinquent_30p_flag,
    case when months_past_due >= 2 then 1 else 0 end as delinquent_60p_flag,
    case when months_past_due >= 3 then 1 else 0 end as delinquent_90p_flag
from statements
