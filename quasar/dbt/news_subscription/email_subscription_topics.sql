SELECT DISTINCT
	_id as id,
	(audit #>> '{email_subscription_topics,updated_at,date}')::timestamptz AS email_subs_updated,
	CASE 
		WHEN u.email_subscription_topics::text like '%community%'
		THEN true 
		ELSE NULL END 
		AS "community_subscription_status",
	CASE 
		WHEN u.email_subscription_topics::text like '%news%'
		THEN true 
		ELSE NULL END 
		AS "news_subscription_status",
	CASE 
		WHEN u.email_subscription_topics::text like '%lifestyle%'
		THEN true 
		ELSE NULL END 
		AS "lifestyle_subscription_status",
	CASE 
		WHEN u.email_subscription_topics::text like '%scholarships%'
		THEN true 
		ELSE NULL END 
		AS "scholarships_subscription_status"
FROM {{ env_var('NORTHSTAR_FIVETRAN') }}.northstar_users_snapshot u
WHERE audit #>> '{email_subscription_topics,updated_at,date}' IS NOT null
