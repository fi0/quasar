SELECT
	u.id AS northstar_id,
	u.created_at,
	umax.max_last_auth AS last_logged_in,
	umax.max_last_access AS last_accessed,
	umax.max_last_message AS last_messaged_at,
	u.drupal_id AS drupal_uid,
	u."source",
	u.email,
	u.facebook_id,
	u.mobile,
	CASE WHEN
		u.birthdate < '1900-01-01' OR 
		u.birthdate > (date('now') - INTERVAL '10 years') 
		THEN NULL ELSE u.birthdate END AS birthdate,
	u.first_name,
	u.last_name,
	u.voter_registration_status,
	u.addr_street1 AS address_street_1,
	u.addr_street2 AS address_street_2,
	u.addr_city AS city,
	u.addr_state AS state,
	u.addr_zip AS zipcode,
	u.country,
	u."language",
	email_status.event_type AS cio_status,
	email_status."timestamp" AS cio_status_timestamp,
	u.sms_status,
	u.source_detail,
	substring(u.source_detail from '(?<=utm_medium\:)(\w*)') AS utm_medium,
	substring(u.source_detail from '(?<=utm_source\:)(\w*)') AS utm_source,
	substring(u.source_detail from '(?<=utm_campaign\:)(\w*)') AS utm_campaign,
	(u.feature_flags #>> '{badges}')::boolean as badges,
	(u.feature_flags #>> '{refer-friends}')::boolean as refer_friends,
	(u.feature_flags #>> '{refer-friends-scholarship}')::boolean as refer_friends_scholarship,
	CASE WHEN
		u.sms_status in ('active','less','pending') OR
		email_status.event_type = 'customer_subscribed' 
		THEN TRUE ELSE FALSE END AS subscribed_member,
	umax.max_update AS last_updated_at,
	u.school_id
FROM northstar.users u
INNER JOIN
	(SELECT
		utemp.id,
		max(utemp.updated_at) AS max_update,
		max(utemp.last_accessed_at) AS max_last_access,
		max(utemp.last_authenticated_at) AS max_last_auth,
		max(utemp.last_messaged_at) AS max_last_message
	FROM northstar.users utemp
	GROUP BY utemp.id) umax ON umax.id = u.id AND umax.max_update = u.updated_at
LEFT JOIN {{ ref('cio_latest_status') }} email_status ON email_status.customer_id = u.id
WHERE
	(u."source" IS DISTINCT FROM 'runscope'
	AND u."source" IS DISTINCT FROM 'runscope-client'
	AND u.email NOT SIMILAR TO '%runscope%@%'
	AND u.email NOT SIMILAR TO '%@%dosomething%') OR u.email IS NULL
