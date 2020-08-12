-- Source https://discourse.getdbt.com/t/examples-of-custom-schema-tests/181/2
{% macro test_not_null_where(model, column_name, condition) %}

  with exceptions as (
    select
      count(*)

    from
      {{ model }}

    where
      {{ column_name }} is null
      and {{ condition }}

  )

  select * from exceptions

{% endmacro %}
