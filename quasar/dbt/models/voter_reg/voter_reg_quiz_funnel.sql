WITH best_nsid AS (
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
)
,
nsid_less AS (
	SELECT 
		pec.device_id,
		--Earliest page visit
		min(pec.event_datetime) AS journey_begin_ts,
		--Latest click to rock the vote page event
		max(pec.event_datetime) 
			FILTER(WHERE pec.event_name='phoenix_clicked_voter_registration_action') AS max_click_registration_ts,
		--Latest quiz submission
		max(pec.event_datetime) 
			FILTER(WHERE pec.event_name='phoenix_submitted_quiz') AS max_submit_quiz_ts,
		--Latest registration timestamp for northstar
		max(reg.started_registration) AS latest_register_ts,
		--Latest start RTV process for northstar
		max(rtv.started_registration) AS latest_get_started_ts,
		--Latest submit photo timestamp
		max(pec.event_datetime)
			FILTER(WHERE pec.event_name IN 
				('phoenix_failed_post_request','phoenix_completed_post_request',
				'phoenix_found_post_request','phoenix_submitted_photo_submission_action',
				'phoenix_completed_photo_submission_action','phoenix_failed_photo_submission_action')
				) AS max_submit_photo_ts,
		--Latest FB share timestamp
		max(pec.event_datetime)
			FILTER(WHERE pec.event_name='phoenix_clicked_share_action_facebook') AS max_fb_share_ts,
		--Create traffic source groupings
		max(
			CASE 
				WHEN pec.page_utm_campaign ILIKE '%niche%' THEN 'niche'
				WHEN pec.page_utm_campaign ILIKE '%fastweb%' THEN 'fastweb'
				WHEN pec.referrer_host ILIKE '%dosomething%' THEN 'dosomething'
				ELSE 'other' END
			) AS traffic_source, 
		--All of the below create dummies for whether an event has ever been connected to a device
		max(
			CASE 
				WHEN pec.event_name IN 
					('visit','view','phoenix_clicked_signup',
					'phoenix_clicked_voter_registration_action') 
				THEN 1 ELSE 0 END
			) AS page_visit,
		max(
			CASE 
				WHEN pec.event_name='phoenix_clicked_signup' 
				THEN 1 ELSE 0 END
			) AS click_join_us,
		max(
			CASE 
				WHEN pec.northstar_id IS NOT NULL 
				THEN 1 ELSE 0 END
			) AS authenticated,
		max(
			CASE 
				WHEN pec.event_name='phoenix_clicked_voter_registration_action' 
				THEN 1 ELSE 0 END
			) AS click_start_registration,
		max(
			CASE 
				WHEN rtv.post_id IS NOT NULL 
				THEN 1 ELSE 0 END
			) AS clicked_get_started,	
		max(
			CASE 
				WHEN rtv.status IN ('Step 2','Step 3','Step 4','Rejected','Under 18','Complete')
				AND rtv.tracking_source ILIKE '%VoterRegQuiz_Affirmation%'
				THEN 1 ELSE 0 END
			) AS rtv_step_2_affirmation,
		max(
			CASE 
				WHEN rtv.status IN ('Step 2','Step 3','Step 4','Rejected','Under 18','Complete')
				AND rtv.tracking_source ILIKE '%VoterRegQuiz_completed%'
				THEN 1 ELSE 0 END
			) AS rtv_step_2_quizcomplete,
		max(
			CASE 
				WHEN rtv.status IN ('Step 3','Step 4','Rejected','Under 18','Complete')
				AND rtv.tracking_source ILIKE '%VoterRegQuiz_Affirmation%'
				THEN 1 ELSE 0 END
			) AS rtv_step_3_affirmation,
		max(
			CASE 
				WHEN rtv.status IN ('Step 3','Step 4','Rejected','Under 18','Complete')
				AND rtv.tracking_source ILIKE '%VoterRegQuiz_completed%'
				THEN 1 ELSE 0 END
			) AS rtv_step_3_quizcomplete,
		max(
			CASE 
				WHEN rtv.status IN ('Step 4','Rejected','Under 18','Complete')
				AND rtv.tracking_source ILIKE '%VoterRegQuiz_Affirmation%'
				THEN 1 ELSE 0 END
			) AS rtv_step_4_affirmation,
		max(
			CASE 
				WHEN rtv.status IN ('Step 4','Rejected','Under 18','Complete')
				AND rtv.tracking_source ILIKE '%VoterRegQuiz_completed%'
				THEN 1 ELSE 0 END
			) AS rtv_step_4_quizcomplete,
		max(
			CASE 
				WHEN rtv.status IN ('Step 3','Step 4','Rejected','Under 18','Complete')
				AND rtv.tracking_source ILIKE '%VoterRegQuiz_Affirmation%'
				THEN 1 ELSE 0 END
			) AS rtv_step_3_or_4_affirmation,
		max(
			CASE 
				WHEN rtv.status IN ('Step 3','Step 4','Rejected','Under 18','Complete')
				AND rtv.tracking_source ILIKE '%VoterRegQuiz_completed%'
				THEN 1 ELSE 0 END
			) AS rtv_step_3_or_4_quizcomplete,
		max(
			CASE 
				WHEN rtv.post_id IS NOT NULL AND rtv.tracking_source ILIKE '%VoterRegQuiz_Affirmation%'
				THEN 1 ELSE 0 END
			) AS clicked_get_started_affirmation,
		max(
			CASE 
				WHEN rtv.post_id IS NOT NULL AND rtv.tracking_source ILIKE '%VoterRegQuiz_completed%'
				THEN 1 ELSE 0 END
			) AS clicked_get_started_quizcomplete,
		max(
			CASE 
				WHEN reg.northstar_id IS NOT NULL 
				THEN 1 ELSE 0 END
			) AS registered,
		max(
			CASE 
				WHEN reg.northstar_id IS NOT NULL AND reg.tracking_source ILIKE '%VoterRegQuiz_completed%'
				THEN 1 ELSE 0 END
			) AS registered_quizcomplete,
		max(
			CASE 
				WHEN reg.northstar_id IS NOT NULL AND reg.tracking_source ILIKE '%VoterRegQuiz_Affirmation%'
				THEN 1 ELSE 0 END
			) AS registered_affirmation,
		max(
			CASE 
				WHEN pec.event_name='phoenix_clicked_share_action_facebook' 
				THEN 1 ELSE 0 END
			) AS clicked_share_fb,
		max(
			CASE 
				WHEN pec.event_name='phoenix_submitted_quiz' 
				THEN 1 ELSE 0 END
			) AS submitted_quiz,
		max(
			CASE 
				WHEN pec.event_name IN 
				('phoenix_failed_post_request','phoenix_completed_post_request',
				'phoenix_found_post_request','phoenix_submitted_photo_submission_action',
				'phoenix_completed_photo_submission_action','phoenix_failed_photo_submission_action')
				THEN 1 ELSE 0 END
			) AS clicked_submit_photo
	FROM {{ ref('phoenix_events_combined') }} pec 
	--Get voter reg activity
	LEFT JOIN 
		(SELECT 
			r.northstar_id,
			rock.tracking_source,
			rock.started_registration 
		FROM {{ ref('reportbacks') }} r 
		LEFT JOIN {{ ref('rock_the_vote') }} rock 
			ON rock.post_id = r.post_id 
		WHERE 
			r.post_bucket = 'voter_registrations'
			) reg 
			ON reg.northstar_id = pec.northstar_id 
	LEFT JOIN {{ ref('posts') }} po ON po.northstar_id=pec.northstar_id
	LEFT JOIN {{ ref('rock_the_vote') }} rtv ON rtv.post_id=po.id AND rtv.status IS NOT NULL 
	WHERE 
		--Filter to the URL we care about
		pec."path" ILIKE '%ready-vote%'
		--Filter to the events we care about
		AND pec.event_name IN (
			'phoenix_clicked_share_action_facebook',
			'phoenix_clicked_signup',
			'phoenix_clicked_voter_registration_action',
			'phoenix_submitted_quiz',
			'phoenix_failed_post_request',
			'phoenix_completed_post_request',
			'phoenix_found_post_request',
			'phoenix_submitted_photo_submission_action',
			'phoenix_completed_photo_submission_action',
			'phoenix_failed_photo_submission_action',
			'visit',
			'view'
		)
	GROUP BY pec.device_id
	--Fix for missing legacy visit events
	HAVING max(CASE WHEN pec.event_name IN 
		('visit','view','phoenix_clicked_signup','phoenix_clicked_voter_registration_action') 
			THEN 1 ELSE 0 END)=1
	)	
--Attaches northstar per first CTE to funnel table
SELECT 
	t.*,
	n.northstar_id,
	--Additional requested funnel paths
	CASE 
		WHEN t.registered_affirmation=1 AND t.max_submit_quiz_ts > t.max_click_registration_ts 
		THEN 1 ELSE 0 END AS register_affirmation_then_quiz,
	CASE
		WHEN t.submitted_quiz=1 AND t.registered_affirmation=1 AND t.max_submit_quiz_ts < t.max_click_registration_ts 
		THEN 1 ELSE 0 END AS submit_quiz_register_affirmation,
	CASE 
		WHEN t.submitted_quiz=1 AND t.registered_affirmation=1 AND 
		t.max_submit_quiz_ts > t.latest_register_ts AND t.max_fb_share_ts > t.max_submit_quiz_ts
		THEN 1 ELSE 0 END AS share_quiz_post_register_affirm,
	CASE 
		WHEN t.submitted_quiz=1 AND t.registered_affirmation=1 AND
		t.max_submit_quiz_ts > t.latest_register_ts AND t.max_submit_photo_ts > t.max_submit_quiz_ts
		THEN 1 ELSE 0 END AS submit_photo_post_register_affirm,
	CASE 
		WHEN t.submitted_quiz=1 AND t.registered_quizcomplete=1 AND
		t.max_submit_quiz_ts > t.latest_register_ts AND t.max_fb_share_ts > t.max_submit_quiz_ts
		THEN 1 ELSE 0 END AS share_quiz_post_register_qcomp,
	CASE 
		WHEN t.submitted_quiz=1 AND t.registered_quizcomplete=1 AND
		t.max_submit_quiz_ts > t.latest_register_ts AND t.max_submit_photo_ts > t.max_submit_quiz_ts
		THEN 1 ELSE 0 END AS submit_photo_post_register_qcomp
FROM nsid_less t
LEFT JOIN best_nsid n ON t.device_id=n.device_id