select
    repayment_status_code,
    description,
    months_past_due,
    delinquency_bucket,
    bucket_order,
    is_documented
from {{ ref('repayment_statuses') }}
