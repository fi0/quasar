SELECT DISTINCT
	f.id,
	f.newsletter_type,
	f.topic_subscribed_at,
	f.topic_updated_at,
	CASE WHEN unsubscribed_at IS NOT NULL 
		THEN unsubscribed_at
		WHEN f.topic_updated_at = f.user_updated_at
		THEN NULL 
		ELSE f.user_updated_at END AS unsubscribed_at
FROM (
	SELECT DISTINCT 
		s.id,
		s.newsletter_type,
		first_value(s.newsletter_updated_at) OVER (PARTITION BY s.id, s.newsletter_type ORDER BY s.newsletter_updated_at
			) AS topic_subscribed_at,
		last_value(s.newsletter_updated_at) OVER (PARTITION BY s.id, s.newsletter_type ORDER BY s.newsletter_updated_at
			ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS topic_updated_at,	
		last_value(s.newsletter_updated_at) OVER (PARTITION BY s.id ORDER BY s.newsletter_updated_at
			ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS user_updated_at,
		s.newsletter_updated_at AS unsubscribed_at
	FROM {{ ref('email_subscription_topics_raw') }} s
	LEFT JOIN (
		SELECT 
			_id AS id,
			to_timestamp(audit #>> '{email_subscription_topics,updated_at,date}', 'YYYY-MM-DD HH24:MI:SS') AS unsubscribed_at,
			NULL AS newsletter_type
		FROM {{ env_var("NORTHSTAR_FT_SCHEMA") }}.northstar_users_snapshot
		WHERE email_subscription_topics IS NULL 
	) u ON u.id = s.id
) f
