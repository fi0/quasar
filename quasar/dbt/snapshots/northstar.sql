/*
  This snapshot table will live in:
    northstar_ft_userapi.northstar_users_snapshot
*/

{% snapshot northstar_users_snapshot %}

    {{
        config(
          target_database=env_var("PG_DATABASE"),
          target_schema=env_var("NORTHSTAR_FT_SCHEMA"),
          unique_key='_id',
          strategy='timestamp',
          updated_at='updated_at',
        )
    }}
    
    select * from {{ source('northstar', 'users') }}
    
{% endsnapshot %}
