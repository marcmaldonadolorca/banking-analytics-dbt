-- Reconciliation: the monthly KPI mart must tie back to the statement fact, month by month,
-- for account counts, balances and delinquent accounts. Returns the months that do not tie.
with fact_totals as (

    select
        statement_month,
        count(*) as accounts,
        sum(bill_amount_ntd) as total_balance_ntd,
        sum(delinquent_30p_flag) as delinquent_30p_accounts,
        sum(delinquent_90p_flag) as delinquent_90p_accounts
    from {{ ref('fct_card_statements') }}
    group by statement_month

)

select
    fact_totals.statement_month,
    fact_totals.accounts as fact_accounts,
    kpis.accounts as kpi_accounts,
    fact_totals.total_balance_ntd as fact_balance,
    kpis.total_balance_ntd as kpi_balance
from fact_totals
full outer join {{ ref('monthly_portfolio_kpis') }} as kpis
    on fact_totals.statement_month = kpis.statement_month
where kpis.statement_month is null
    or fact_totals.statement_month is null
    or fact_totals.accounts != kpis.accounts
    or fact_totals.total_balance_ntd != kpis.total_balance_ntd
    or fact_totals.delinquent_30p_accounts != kpis.delinquent_30p_accounts
    or fact_totals.delinquent_90p_accounts != kpis.delinquent_90p_accounts
