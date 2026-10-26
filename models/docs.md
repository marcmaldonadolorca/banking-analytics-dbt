{% docs credit_limit_ntd %}
Credit limit granted to the client (individual plus supplementary cards), in NT$.
The extract carries a single value per client, so it is treated as constant over the six months.
{% enddocs %}

{% docs repayment_status_code %}
Monthly repayment status as delivered by the issuer: -2 no consumption, -1 paid in full,
0 revolving credit (minimum paid), 1-8 payment delayed that many months, 9 nine months or more.
Codes -2 and 0 are not described on the UCI page; the meaning used here is the one commonly
attributed to the dataset author. See the `repayment_statuses` seed.
{% enddocs %}

{% docs delinquency_bucket %}
Collections bucket derived from the repayment status: `current` (codes -2, -1, 0),
`30_dpd` (1 month late), `60_dpd` (2 months late) and `90_plus_dpd` (3 or more months late).
{% enddocs %}

{% docs utilization_ratio %}
Statement balance divided by the credit limit. Negative balances (credit in favour of the
client) count as zero utilisation; values above 1 mean the account is over its limit.
{% enddocs %}

{% docs payment_amount_ntd %}
Amount the client paid during the statement month, in NT$. It settles the previous
month's statement, which is why payment rates compare it with `previous_bill_amount_ntd`.
{% enddocs %}

{% docs delinquent_flags %}
1 if the account is at least 30 / 60 / 90 days past due on this statement, else 0.
Integers rather than booleans so they can be summed on any warehouse.
{% enddocs %}
