SELECT id AS post_id, 
   details::jsonb->>'Tracking Source' AS tracking_source,
   (details::jsonb->>'Started registration')::timestamp AS started_registration,
   details::jsonb->>'Finish with State' AS finish_with_state,
   details::jsonb->>'Status' AS status,
   details::jsonb->>'Email address' AS email,
   details::jsonb->>'Home zip code' AS zip
 FROM "quasar_prod_warehouse"."dbt_sena_ft_dosomething_rogue"."posts"
 WHERE source = 'rock-the-vote'