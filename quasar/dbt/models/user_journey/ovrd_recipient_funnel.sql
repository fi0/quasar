SELECT 
	bc.northstar_id,
	min(bc.click_time) AS journey_begin_ts,
	max(
		CASE
			WHEN bc.click_id IS NOT NULL THEN 1 ELSE 0 END
		) AS clicked_link,
	max(
		CASE 
			WHEN rtv.status IS NOT NULL THEN 1 ELSE 0 END
	) AS clicked_get_started,
	max(
		CASE 
			WHEN rb.northstar_id IS NOT NULL THEN 1 ELSE 0 END 
	) AS completed_registration
FROM {{ ref('bertly_clicks') }} bc
LEFT JOIN {{ ref('posts') }} po ON bc.northstar_id=po.northstar_id
LEFT JOIN {{ ref('rock_the_vote') }} rtv ON po.id=rtv.post_id
LEFT JOIN {{ ref('reportbacks') }} rb ON rtv.post_id=rb.post_id AND rb.post_bucket = 'voter_registrations'
WHERE 
	bc.target_url ILIKE '%vote.dosomething.org/member-drive%'
	AND bc.northstar_id IS NOT NULL
	AND bc.target_url ILIKE '%referral=true%'
	AND bc.interaction_type = 'click'
	AND (rtv.started_registration >= '2018-01-01' OR rtv.started_registration IS NULL)
GROUP BY bc.northstar_id
