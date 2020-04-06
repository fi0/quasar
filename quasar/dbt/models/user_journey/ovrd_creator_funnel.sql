WITH best_nsid AS (
	SELECT 
		ranked.device_id,
		ranked.northstar_id
	FROM 
		(SELECT 
			oc.device_id,
			oc.northstar_id,
			ROW_NUMBER() OVER (PARTITION BY oc.device_id ORDER BY oc.occurances DESC) AS ord 
		FROM 
			(SELECT DISTINCT 
				pec.device_id,
				pec.northstar_id,
				count(*) AS occurances
			FROM {{ ref('phoenix_events_combined') }} pec  
			WHERE pec.northstar_id IS NOT NULL
			GROUP BY pec.device_id, pec.northstar_id) oc
			) ranked
	WHERE ranked.ord=1
)
,
nsid_less AS (
	SELECT 
		pec.device_id,
		min(pec.event_datetime) AS journey_begin_ts,
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
				WHEN reg.northstar_id IS NOT NULL 
				THEN 1 ELSE 0 END
			) AS registered,
		max(
			CASE 
				WHEN pec.event_name='phoenix_clicked_copy_to_clipboard' 
				THEN 1 ELSE 0 END
			) AS click_copy_link,
		max(
			CASE 
				WHEN pec.event_name IN 
					('phoenix_clicked_share_action_facebook','phoenix_clicked_share_email',
					'phoenix_clicked_share_facebook_messenger','phoenix_clicked_share_twitter')
				THEN 1 ELSE 0 END
			) AS clicked_any_share,
		max(
			CASE 
				WHEN pec.event_name='phoenix_clicked_share_action_facebook' 
				THEN 1 ELSE 0 END
			) AS clicked_share_fb,
		max(
			CASE 
				WHEN pec.event_name='phoenix_clicked_share_email' 
				THEN 1 ELSE 0 END
			) AS clicked_share_email ,
		max(
			CASE 
				WHEN pec.event_name='phoenix_clicked_share_facebook_messenger' 
				THEN 1 ELSE 0 END
			) AS clicked_share_fb_msgr,
		max(
			CASE 
				WHEN pec.event_name='phoenix_clicked_share_twitter' 
				THEN 1 ELSE 0 END
			) AS clicked_share_twitter
	FROM {{ ref('phoenix_events_combined') }} pec 
	LEFT JOIN 
		(SELECT 
			r.northstar_id
		FROM {{ ref('reportbacks') }} r 
		LEFT JOIN {{ ref('rock_the_vote') }} rock 
			ON rock.post_id = r.post_id 
		WHERE 
			r.post_bucket = 'voter_registrations'
			AND rock.tracking_source ILIKE '%LYVCaffirmation%'
			) reg 
			ON reg.northstar_id = pec.northstar_id 
	LEFT JOIN {{ ref('posts') }} po ON po.northstar_id=pec.northstar_id
	LEFT JOIN {{ ref('rock_the_vote') }} rtv ON rtv.post_id=po.id AND rtv.status IS NOT NULL 
	LEFT JOIN best_nsid ON best_nsid.device_id=pec.device_id 
	WHERE 
		pec."path" ILIKE '%online-registration-drive%'
		AND pec.event_name IN (
			'phoenix_clicked_copy_to_clipboard',
			'phoenix_clicked_share_action_facebook',
			'phoenix_clicked_share_email',
			'phoenix_clicked_share_facebook_messenger',
			'phoenix_clicked_share_twitter',
			'phoenix_clicked_signup',
			'phoenix_clicked_voter_registration_action',
			'phoenix_opened_modal',
			'visit',
			'view'
		)
	GROUP BY pec.device_id
	HAVING max(CASE WHEN pec.event_name IN 
		('visit','view','phoenix_clicked_signup','phoenix_clicked_voter_registration_action') 
			THEN 1 ELSE 0 END)=1
	)		
SELECT 
	nsid_less.*,
	best_nsid.northstar_id
FROM nsid_less
LEFT JOIN best_nsid ON nsid_less.device_id=best_nsid.device_id