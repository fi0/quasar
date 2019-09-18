SELECT 
	_id as id,
	updated_at,
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
