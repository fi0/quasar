SELECT
	pd.northstar_id as northstar_id,
	pd.id AS id,
	pd."type" AS "type",
	a."name" AS "action",
	pd.status AS status,
	pd.quantity AS quantity,
	pd.campaign_id,
	CASE
		WHEN pd.id IS NULL THEN NULL
		WHEN a."name" = 'voter-reg OTG'
		THEN pd.quantity
		ELSE 1 END AS reportback_volume,
	pd."source" AS "source",
	CASE
		WHEN pd."source" IS NULL THEN NULL
		WHEN pd."source" ilike '%%sms%%' THEN 'sms'
		ELSE 'web' END AS source_bucket,
	CASE
		WHEN pd."type" = 'phone-call'
		THEN (pd.details::json ->> 'call_timestamp')::timestamptz
		ELSE COALESCE(rtv.created_at, tv.created_at, pd.created_at)
		END AS created_at,
	pd.url AS url,
	pd.text,
	CASE
		WHEN s."source" = 'importer-client'
		AND pd."type" = 'share-social'
		AND pd.created_at < s.created_at
		THEN -1
		ELSE pd.signup_id END AS signup_id,
	CASE
		WHEN pd.id IS NULL
		THEN NULL
		ELSE CONCAT(pd."type", ' - ', a."name") END AS post_class,
	CASE WHEN pd.status IN ('accepted', 'pending')
		AND a."name" NOT ILIKE '%%vote%%'
		THEN 1
		WHEN pd.status IN ('accepted', 'confirmed', 'register-OVR', 'register-form')
		AND a."name" ILIKE '%%vote%%'
		THEN 1
		ELSE NULL END AS is_accepted,
	pd.action_id,
	pd.location,
	pd.postal_code,
	a.reportback AS is_reportback,
	a.civic_action,
	a.scholarship_entry
FROM ft_dosomething_rogue.posts pd
INNER JOIN "quasar_prod_warehouse"."public"."signups" s
	ON pd.signup_id = s.id
LEFT JOIN "quasar_prod_warehouse"."public"."turbovote" tv
	ON tv.post_id::bigint = pd.id::bigint
LEFT JOIN
	(SELECT
		DISTINCT r.*,
		CASE
			WHEN r.started_registration < '2017-01-01'
			THEN r.started_registration + interval '4 year'
			ELSE r.started_registration END AS created_at
		FROM "quasar_prod_warehouse"."public"."rock_the_vote" r
	) rtv
	ON rtv.post_id::bigint = pd.id::bigint
LEFT JOIN ft_dosomething_rogue.actions a
	ON pd.action_id = a.id
WHERE pd.deleted_at IS NULL
AND pd."text" IS DISTINCT FROM 'test runscope upload'
AND a."name" IS NOT NULL