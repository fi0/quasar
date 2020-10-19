-- This Macro tests that the row with a given column value
-- is not orphan by searching for the value in a model and field that should
-- contain the entity.

-- Example of the arguments passed to this macro
-- model: public.snowplow_base_event (provided by DBT - Model being tested in schema.yml)
-- column_name: northstar_id (provided by DBT -- column being tested in schema.yml)
-- to: public.users (provided by user -- "to" model to compare against)
-- field: northstar_id (provided by user -- "field" in "to" model to compare against)
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
