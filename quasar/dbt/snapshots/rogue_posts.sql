/*
  This snapshot table will live in:
    ft_dosomething_rogue.rogue_posts
*/

{% snapshot rogue_posts_snapshot %}

    {{
        config(
          target_database=env_var("NORTHSTAR_TARGET_DB"),
          target_schema=env_var("FT_ROGUE"),
          unique_key='id',
          strategy='timestamp',
          updated_at='updated_at',
        )
    }}
    
    select * from {{ env_var('FT_ROGUE') }}.posts
    
{% endsnapshot %}
