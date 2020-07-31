{% macro test_relationships_distinct(model, field, to, column_name) %}

SELECT
    count(DISTINCT {{"a.%s" | format(column_name) }}) AS orphan_ids
FROM
    {{"%s a" | format(model) }}
    LEFT JOIN {{"%s b" | format(to) }} ON {{"a.%s" | format(column_name) }} = {{"b.%s" | format(field) }}
WHERE
    {{"a.%s" | format(column_name) }} IS NOT NULL
    AND {{"b.%s" | format(field) }} IS NULL

{% endmacro %}
