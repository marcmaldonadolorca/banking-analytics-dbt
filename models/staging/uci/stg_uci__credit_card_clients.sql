with source as (

    select * from {{ source('uci', 'credit_card_clients') }}

),

renamed as (

    select
        cast(id as integer) as customer_id,
        cast(limit_bal as bigint) as credit_limit_ntd,
        case sex when 1 then 'male' when 2 then 'female' end as sex,
        cast(education as integer) as education_code,
        cast(marriage as integer) as marital_status_code,
        cast(age as integer) as age_years,

        -- The source numbers repayment status pay_0, pay_2 ... pay_6 (there is no pay_1) while
        -- bills and payments run 1 ... 6. In all three, 1/0 = September 2005 and 6 = April 2005.
        cast(pay_0 as integer) as repayment_status_2005_09,
        cast(pay_2 as integer) as repayment_status_2005_08,
        cast(pay_3 as integer) as repayment_status_2005_07,
        cast(pay_4 as integer) as repayment_status_2005_06,
        cast(pay_5 as integer) as repayment_status_2005_05,
        cast(pay_6 as integer) as repayment_status_2005_04,

        cast(bill_amt1 as bigint) as bill_amount_2005_09,
        cast(bill_amt2 as bigint) as bill_amount_2005_08,
        cast(bill_amt3 as bigint) as bill_amount_2005_07,
        cast(bill_amt4 as bigint) as bill_amount_2005_06,
        cast(bill_amt5 as bigint) as bill_amount_2005_05,
        cast(bill_amt6 as bigint) as bill_amount_2005_04,

        cast(pay_amt1 as bigint) as payment_amount_2005_09,
        cast(pay_amt2 as bigint) as payment_amount_2005_08,
        cast(pay_amt3 as bigint) as payment_amount_2005_07,
        cast(pay_amt4 as bigint) as payment_amount_2005_06,
        cast(pay_amt5 as bigint) as payment_amount_2005_05,
        cast(pay_amt6 as bigint) as payment_amount_2005_04,

        default_payment_next_month = 1 as defaulted_next_month,
        _loaded_at as loaded_at

    from source

)

select * from renamed
