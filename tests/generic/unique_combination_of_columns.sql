{#- Fails for every combination of the given columns that appears more than once (composite keys). -#}
{% test unique_combination_of_columns(model, combination_of_columns) %}

select {{ combination_of_columns | join(', ') }}, count(*) as occurrences
from {{ model }}
group by {{ combination_of_columns | join(', ') }}
having count(*) > 1

{% endtest %}
