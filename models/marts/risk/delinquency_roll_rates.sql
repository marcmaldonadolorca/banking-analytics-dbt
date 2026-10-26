with statements as (

    select * from {{ ref('fct_card_statements') }}
    where previous_repayment_status_code is not null

),

repayment_statuses as (

    select * from {{ ref('dim_repayment_status') }}

),

transitions as (

    -- dim_repayment_status plays two roles: last month's status and this month's.
    select
        statements.statement_month,
        previous_status.delinquency_bucket as from_bucket,
        previous_status.bucket_order as from_bucket_order,
        current_status.delinquency_bucket as to_bucket,
        current_status.bucket_order as to_bucket_order,
        count(*) as accounts
    from statements
    inner join repayment_statuses as previous_status
        on statements.previous_repayment_status_code = previous_status.repayment_status_code
    inner join repayment_statuses as current_status
        on statements.repayment_status_code = current_status.repayment_status_code
    group by 1, 2, 3, 4, 5

)

select
    statement_month,
    from_bucket,
    to_bucket,
    case
        when to_bucket_order > from_bucket_order then 'roll_forward'
        when to_bucket_order < from_bucket_order then 'cure'
        else 'stay'
    end as transition_type,
    accounts,
    sum(accounts) over (partition by statement_month, from_bucket) as from_bucket_accounts,
    accounts / sum(accounts) over (partition by statement_month, from_bucket) as roll_rate
from transitions
