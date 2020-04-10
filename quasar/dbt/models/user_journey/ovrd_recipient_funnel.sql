SELECT 
	po.northstar_id,
	min(rtv.started_registration) AS journey_begin_ts,
	max(
		CASE 
			WHEN rtv.status IS NOT NULL THEN 1 ELSE 0 END
	) AS clicked_get_started,
	max(
		CASE 
			WHEN rb.northstar_id IS NOT NULL THEN 1 ELSE 0 END 
	) AS completed_registration
FROM {{ ref('posts') }} po
LEFT JOIN {{ ref('rock_the_vote') }} rtv ON po.id = rtv.post_id
LEFT JOIN {{ ref('reportbacks') }} rb ON rtv.post_id = rb.post_id AND rb.post_bucket = 'voter_registrations'
WHERE 
	rtv.tracking_source ILIKE '%referral=true%'
	AND (rtv.started_registration >= '2018-01-01' OR rtv.started_registration IS NULL)
GROUP BY po.northstar_id