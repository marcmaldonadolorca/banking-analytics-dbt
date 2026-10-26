{{ config(severity='warn') }}

-- Business rule: an account can fall at most one month further behind per month
-- (e.g. 0 -> 2 months past due in a single statement is impossible). This is a known quirk of the
-- source coding (status 1 is almost absent before September 2005), so the test only warns:
-- it documents and counts the violations instead of blocking the build.
select
    customer_id,
    statement_month,
    previous_repayment_status_code,
    repayment_status_code
from {{ ref('fct_card_statements') }}
where previous_repayment_status_code is not null
    and repayment_status_code > greatest(previous_repayment_status_code, 0) + 1
