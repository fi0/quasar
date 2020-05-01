WITH event_log AS (
	--Get the earliest page visit by the user
	SELECT 
		--user_id tries to use the northstar on the event, failing that resorts to CTE below, and finally defaults to device_id
		COALESCE(pec.northstar_id, nsid.northstar_id, pec.device_id) AS user_id,
		--The user journey begins the first time the user lands on the page
		min(pec.event_datetime) AS event_ts,
		'page_visit' AS event_name
	FROM {{ ref('phoenix_events_combined') }} pec 
	LEFT JOIN (
		--This CTE assigns one NSID per device by getting the most frequently occuring nsid-device combo per device
		SELECT 
			ranked.device_id,
			ranked.northstar_id
		FROM 
			(SELECT 
				oc.device_id,
				oc.northstar_id,
				--Gets rank of most frequent pairing
				ROW_NUMBER() OVER (PARTITION BY oc.device_id ORDER BY oc.occurances DESC) AS ord 
			FROM 
				(SELECT DISTINCT 
					--Count device/northstar occurances
					pec.device_id,
					pec.northstar_id,
					count(*) AS occurances
				FROM {{ ref('phoenix_events_combined') }} pec  
				WHERE pec.northstar_id IS NOT NULL
				GROUP BY pec.device_id, pec.northstar_id) oc
				) ranked
		--Choose top ranked per device
		WHERE ranked.ord=1
		) nsid ON nsid.device_id=pec.device_id 
	WHERE 
		--Filter the URL of interest
		pec."path" ILIKE '%my-voter-registration-drive%'
		AND pec.event_name IN ('visit','view')
	GROUP BY COALESCE(pec.northstar_id, nsid.northstar_id, pec.device_id)
	UNION ALL 
	--Union RTV process starts who came from a referral per their tracking source
	SELECT DISTINCT 
		p.northstar_id AS user_id,
		rtv.started_registration AS event_ts, 
		p.status AS event_name
	FROM {{ ref('rock_the_vote') }} rtv 
	LEFT JOIN {{ ref('posts') }} p ON p.id=rtv.post_id
	WHERE 
		rtv.tracking_source ILIKE '%referral=true%'
	UNION ALL 
	--Union voter reg reportbacks to capture registration events
	SELECT 
		rb.northstar_id AS user_id,
		rb.post_created_at AS event_ts,
		'registered' AS event_name
	FROM {{ ref('reportbacks') }} rb
	INNER JOIN {{ ref('rock_the_vote') }} rtv ON rb.post_id=rtv.post_id
	WHERE 
		rb.post_bucket = 'voter_registrations'
		AND rtv.tracking_source ILIKE '%referral=true%'
	)
--Collapse the event log to a user level table with flags and timestamps
SELECT 
	lg.user_id,
	--Earliest ts on record is when their journey began
	min(lg.event_ts) AS journey_begin_ts,
	--You must have visited the page if you are in the event log (allows us to 'backfill' some of the missing info
	1 AS page_visit,
	--Earliest RTV record for the user is when they began registering
	min(lg.event_ts)
		FILTER(WHERE lg.event_name<>'page_visit') AS started_register_ts,
	--If they have a started_registration event then they clicked get started
	max(
		CASE 
			WHEN lg.event_name IS NOT NULL THEN 1 ELSE 0 END
		) AS clicked_get_started,
		max(
			CASE 
				WHEN po.event_name IN (('step-2','step-3','step-4','ineligible','under-18','register-OVR','register-form'))
				THEN 1 ELSE 0 END
			) AS rtv_step_2,
		max(
			CASE 
				WHEN po.event_name IN ('step-3','ineligible','under-18','register-form')
				THEN 1 ELSE 0 END
			) AS rtv_step_3,
		max(
			CASE 
				WHEN po.event_name IN ('step-4','ineligible','under-18','register-OVR')
				THEN 1 ELSE 0 END
			) AS rtv_step_4,
		max(
			CASE 
				WHEN po.event_name IN ('step-3','step-4','ineligible','under-18','register-OVR','register-form')
				THEN 1 ELSE 0 END
			) AS rtv_step_3_or_4,
	--If they have a registration event then they registered
	max(
		CASE 
			WHEN lg.event_name='registered' THEN 1 ELSE 0 END
		) AS registered
FROM event_log lg
GROUP BY lg.user_id