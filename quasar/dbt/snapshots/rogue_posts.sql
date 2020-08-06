/*
  This snapshot table will live in:
    ft_dosomething_rogue.rogue_posts
*/

{% snapshot rogue_posts_snapshot %}

    {{
        config(
          target_database=env_var("PG_DATABASE"),
          target_schema=env_var("FT_ROGUE"),
          unique_key='id',
          strategy='timestamp',
          updated_at='updated_at',
        )
    }}
    
    select * from {{ source('rogue', 'posts') }}
    
{% endsnapshot %}
