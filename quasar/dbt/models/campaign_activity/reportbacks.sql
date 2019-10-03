SELECT
pd.northstar_id,
pd.id as post_id,
pd.signup_id,
pd.campaign_id,
pd."action" as post_action,
pd."type" as post_type,
pd.status as post_status,
pd.post_class,
pd.created_at as post_created_at,
pd.source as post_source,
pd.source_bucket as post_source_bucket,
pd.reportback_volume,
pd.civic_action,
pd.scholarship_entry,
pd.location,
pd.postal_code,
CASE WHEN (pd.post_class ilike '%%vote%%' AND pd.status = 'confirmed')
     THEN 'self-reported registrations'
     WHEN (pd.post_class ilike '%%vote%%' AND pd.status <> 'confirmed')
     THEN 'voter_registrations'
     WHEN pd.post_class ilike '%%photo%%'
     THEN 'photo_rbs'
     WHEN pd.post_class ilike '%%text%%'
     THEN 'text_rbs'
     WHEN pd.post_class ilike '%%social%%'
     THEN 'social'
     WHEN pd.post_class ilike '%%call%%'
     THEN 'phone_calls'
     ELSE NULL END AS post_bucket
FROM
{{ ref('posts') }} pd
WHERE pd.id IN (
	  SELECT min(id)
  FROM {{ ref('posts') }} p
  WHERE p.is_reportback = 'true'
  	 AND p.is_accepted = 1
  GROUP BY p.northstar_id, p.campaign_id, p.signup_id, p.post_class, p.reportback_volume
  )
