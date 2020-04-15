WITH best_nsid AS (
	--Determines best bsid by choosing most frequently occuring nsid for device
	SELECT 
		ranked.device_id,
		ranked.northstar_id
	FROM 
		(SELECT 
			oc.device_id,
			oc.northstar_id,
			--Order by occurances by device and set within group row numbers
			ROW_NUMBER() OVER (PARTITION BY oc.device_id ORDER BY oc.occurances DESC) AS ord 
		FROM 
			(SELECT DISTINCT 
				--Count occurances by device/northstar combo
				pec.device_id,
				pec.northstar_id,
				count(*) AS occurances
			FROM {{ ref('phoenix_events_combined') }} pec  
			WHERE pec.northstar_id IS NOT NULL
			GROUP BY pec.device_id, pec.northstar_id) oc
			) ranked
	--Choose top ranked combo
	WHERE ranked.ord=1
)
,
referral_counts AS (
	--Get referral counts
	SELECT 
		--Prefer referrer_user_id on post, extract value from tracking source for legacy posts
		COALESCE(p.referrer_user_id, split_part(substring(tracking_source from 'user\:(.+)\,'), ',', 1)) AS referrer,
		count(*) AS referrals_start,
		sum(CASE WHEN rtv.status='Complete' THEN 1 ELSE 0 END) AS referrals_completed
	FROM {{ ref('posts') }} p 
	INNER JOIN {{ ref('rock_the_vote') }} rtv ON p.id=rtv.post_id 
	WHERE 
		--Must be referral
		rtv.tracking_source ILIKE '%referral=true%'
		--Exclude nonsense or empty nsid values
		AND COALESCE(p.referrer_user_id, split_part(substring(tracking_source from 'user\:(.+)\,'), ',', 1)) 
			NOT IN ('{userId}','null', '')
	GROUP BY COALESCE(p.referrer_user_id, split_part(substring(tracking_source from 'user\:(.+)\,'), ',', 1))
	)
,
nsid_less AS (
	SELECT 
		pec.device_id,
		--Earliest recorded page visit
		min(pec.event_datetime) AS journey_begin_ts,
		--Latest registration timestamp for northstar
		max(reg.started_registration) AS latest_register_ts,
		--Latest start RTV process for northstar
		max(rtv.started_registration) AS latest_get_started_ts,
		--Did they visit? Includes other event types to account for missing visits in puck
		max(
			CASE 
				WHEN pec.event_name IN 
					('visit','view','phoenix_clicked_signup',
					'phoenix_clicked_voter_registration_action') 
				THEN 1 ELSE 0 END
			) AS page_visit,
		--Funnel flags
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
			) AS clicked_share_email,
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
	--Join reportbacks to determine if they registered via the source we care about
	LEFT JOIN 
		(SELECT 
			r.northstar_id,
			rock.started_registration 
		FROM {{ ref('reportbacks') }} r 
		LEFT JOIN {{ ref('rock_the_vote') }} rock 
			ON rock.post_id = r.post_id 
		WHERE 
			r.post_bucket = 'voter_registrations'
			--Only registrations with these tracking sources represent completing the funnel
			AND (rock.tracking_source ILIKE '%LYVCaffirmation%'
				OR rock.tracking_source ILIKE '%OnlineRegistrationDrive_affirmation%')
			) reg 
			ON reg.northstar_id = pec.northstar_id 
	LEFT JOIN {{ ref('posts') }} po ON po.northstar_id=pec.northstar_id
	LEFT JOIN {{ ref('rock_the_vote') }} rtv ON rtv.post_id=po.id AND rtv.status IS NOT NULL 
	--Filter to URL of interest
	WHERE 
		pec."path" ILIKE '%online-registration-drive%'
	--Filter to events of interest
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
	--Only consider folks who did at least one of the below on the URL of interest
	HAVING max(CASE WHEN pec.event_name IN 
		('visit','view','phoenix_clicked_signup','phoenix_clicked_voter_registration_action') 
			THEN 1 ELSE 0 END)=1
	)		
SELECT 
	nsid_less.*,
	best_nsid.northstar_id
FROM nsid_less
LEFT JOIN best_nsid ON nsid_less.device_id=best_nsid.device_id
LEFT JOIN referral_counts ON referral_counts.referrer=best_nsid.northstar_id