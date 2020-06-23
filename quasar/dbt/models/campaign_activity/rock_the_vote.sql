SELECT id AS post_id,
   details::jsonb->>'Tracking Source' AS tracking_source,
   (details::jsonb->>'Started registration')::timestamp AS started_registration,
   details::jsonb->>'Finish with State' AS finish_with_state,
   details::jsonb->>'Status' AS status,
   COALESCE(details::jsonb->>'Email address',details::jsonb->>'email') AS email,
   details::jsonb->>'Home zip code' AS zip
 FROM {{ source('rogue', 'posts') }}
 WHERE source = 'rock-the-vote'
