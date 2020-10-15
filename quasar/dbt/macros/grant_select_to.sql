
{% macro grant_select_to(model, roles=[]) %}
    {% if roles is not string and roles|length > 0 %}
        {% for role in roles %}
            {{ 'GRANT SELECT ON ' ~ model ~ ' TO ' ~ role ~ ';' }}
        {% endfor %}
    {% endif %}
{% endmacro %}
