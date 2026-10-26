{#- Statement months present in the extract; staging exposes one column set per month. -#}
{%- set statement_months = ['2005_04', '2005_05', '2005_06', '2005_07', '2005_08', '2005_09'] -%}

with clients as (

    select * from {{ ref('stg_uci__credit_card_clients') }}

),

repayment_statuses as (

    select * from {{ ref('repayment_statuses') }}

),

unpivoted as (

    {% for month in statement_months %}
    select
        customer_id,
        cast('{{ month | replace("_", "-") }}-01' as date) as statement_month,
        credit_limit_ntd,
        repayment_status_{{ month }} as repayment_status_code,
        bill_amount_{{ month }} as bill_amount_ntd,
        payment_amount_{{ month }} as payment_amount_ntd
    from clients
    {% if not loop.last %}union all{% endif %}
    {% endfor %}

),

with_history as (

    -- Window functions run here, over the full history, so the incremental fact can filter
    -- to recent months without losing the previous month's values.
    select
        *,
        lag(bill_amount_ntd) over (
            partition by customer_id order by statement_month
        ) as previous_bill_amount_ntd,
        lag(repayment_status_code) over (
            partition by customer_id order by statement_month
        ) as previous_repayment_status_code
    from unpivoted

)

select
    with_history.customer_id,
    with_history.statement_month,
    with_history.repayment_status_code,
    with_history.previous_repayment_status_code,
    repayment_statuses.months_past_due,
    with_history.credit_limit_ntd,
    with_history.bill_amount_ntd,
    with_history.previous_bill_amount_ntd,
    with_history.payment_amount_ntd,
    greatest(with_history.bill_amount_ntd, 0)
        / nullif(with_history.credit_limit_ntd, 0) as utilization_ratio
from with_history
left join repayment_statuses
    on with_history.repayment_status_code = repayment_statuses.repayment_status_code
