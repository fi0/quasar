-- Source https://discourse.getdbt.com/t/examples-of-custom-schema-tests/181/5
{% macro test_is_between(model, column_name, bottom_number, top_number) %}
    WITH validation AS (
        SELECT
            {{ column_name }} AS field_to_test
        FROM
            {{ model }}
    ),
    validation_errors AS (
        SELECT
            field_to_test
        FROM
            validation
        WHERE
            field_to_test > {{ top_number }}
            OR field_to_test < {{ bottom_number }}
    )
    SELECT
        count(*)
    FROM
        validation_errors
{% endmacro %}
