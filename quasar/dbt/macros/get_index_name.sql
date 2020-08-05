-- This macro helps us to DRY up the generation of index names
-- while also fixing the intermittent index creation bug
-- https://www.pivotaltracker.com/story/show/174129431
{% macro get_index_name(model, idx_name) %}
    {% set prefix = [model.schema, model.table, idx_name] | join('_') %}
    {% set suffix = run_started_at.strftime('%Y%m%d_%H%M%S') %}
    {% set raw_name = [prefix, suffix] | join('_') %}
    -- 63 is the PostgreSQL index name character limit
    -- 16 is the length of the date suffix with leading _
    {% set truncate_limit = 63 - 16 %}

    {% if raw_name | length > 63 %}
        {% set full_name = [prefix | truncate(truncate_limit, True, '_'), suffix] | join('_') %}
    {% else %}
        {% set full_name = raw_name %}
    {% endif %}

    {{ full_name ~ ' ON ' ~ model }}
{% endmacro %}
