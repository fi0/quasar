/*
  This snapshot table will live in:
    public
*/

{% snapshot contentful_metadata_snapshot %}

    {{
        config(
          target_database=env_var("PG_DATABASE"),
          target_schema='public',
          unique_key='contentful_id',
          strategy='check',
          check_cols='all'
        )
    }}
    
    select * from {{ ref('contentful_metadata') }}
    
{% endsnapshot %}
