-- Every account in a bucket last month must land somewhere this month: for each month and
-- origin bucket the roll rates sum to 1 and the transitions cover all accounts of the origin bucket.
select
    statement_month,
    from_bucket,
    sum(roll_rate) as total_roll_rate,
    sum(accounts) as accounts,
    max(from_bucket_accounts) as from_bucket_accounts
from {{ ref('delinquency_roll_rates') }}
group by statement_month, from_bucket
having abs(sum(roll_rate) - 1) > 1e-9
    or sum(accounts) != max(from_bucket_accounts)
