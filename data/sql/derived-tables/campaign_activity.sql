DROP MATERIALIZED VIEW IF EXISTS public.signups CASCADE;
CREATE MATERIALIZED VIEW public.signups AS
    (SELECT
        sd.northstar_id AS northstar_id,
        sd.id AS id,
        sd.campaign_id AS campaign_id,
        sd.campaign_run_id AS campaign_run_id,
        sd.why_participated AS why_participated,
        sd."source" AS "source",
	CASE WHEN sd."source" = 'niche' THEN 'niche'
	     WHEN sd."source" ilike '%%sms%%' THEN 'sms'
	     WHEN sd."source" in ('rock-the-vote', 'turbovote') THEN 'voter-reg'
	     ELSE 'web' END AS source_bucket,
        sd.created_at AS created_at
    FROM ft_dosomething_rogue.signups sd
    WHERE sd._fivetran_deleted = 'false'
	AND sd.deleted_at IS NULL
	AND sd."source" IS DISTINCT FROM 'rogue-oauth'
	AND sd.why_participated IS DISTINCT FROM 'Testing from Ghost Inspector!'
    );
CREATE UNIQUE INDEX ON public.signups (created_at, id);
GRANT SELECT ON public.signups TO looker;
GRANT SELECT ON public.signups TO dsanalyst;

DROP MATERIALIZED VIEW IF EXISTS ft_dosomething_rogue.turbovote CASCADE;
CREATE MATERIALIZED VIEW ft_dosomething_rogue.turbovote AS
	(SELECT id AS post_id, 
			details::jsonb->>'hostname' AS hostname,
			details::jsonb->>'referral_code' AS referral_code,
			details::jsonb->>'partner_comms_opt_in' AS partner_comms_opt_in,
			(details::jsonb->>'created-at')::timestamp AS created_at,
			(details::jsonb->>'updated-at')::timestamp AS updated_at,
			source_details,
			details::jsonb->>'voter_registration_status' AS voter_registration_status,
			details::jsonb->>'voter_registration_source' AS voter_registration_source,
			details::jsonb->>'voter_registration_method' AS voter_registration_method,
			details::jsonb->>'voter_registration_preference' AS voter_registration_preference,
			details::jsonb->>'email_subscribed' AS email_subscribed,
			details::jsonb->>'sms_subscribed' AS sms_subscribed
	 FROM ft_dosomething_rogue.posts
	 WHERE source = 'turbovote');
CREATE UNIQUE INDEX ON ft_dosomething_rogue.turbovote (post_id, created_at, updated_at);
GRANT SELECT ON ft_dosomething_rogue.turbovote TO looker;
GRANT SELECT ON ft_dosomething_rogue.turbovote TO dsanalyst;

DROP MATERIALIZED VIEW IF EXISTS ft_dosomething_rogue.rock_the_vote CASCADE;
CREATE MATERIALIZED VIEW ft_dosomething_rogue.rock_the_vote AS
	(SELECT id AS post_id, 
	   details::jsonb->>'Tracking Source' AS tracking_source,
	   (details::jsonb->>'Started registration')::timestamp AS started_registration,
	   details::jsonb->>'Finish with State' AS finish_with_state,
	   details::jsonb->>'Status' AS status,
	   details::jsonb->>'Email address' AS email,
	   details::jsonb->>'Home zip code' AS zip
	 FROM ft_dosomething_rogue.posts
	 WHERE source = 'rock-the-vote');
CREATE INDEX ON ft_dosomething_rogue.rock_the_vote (post_id, started_registration);
GRANT SELECT ON ft_dosomething_rogue.turbovote TO looker;
GRANT SELECT ON ft_dosomething_rogue.turbovote TO dsanalyst;

DROP MATERIALIZED VIEW IF EXISTS public.posts CASCADE;
CREATE MATERIALIZED VIEW public.posts AS
    (SELECT
	    pd.northstar_id as northstar_id,
	    pd.id AS id,
	    pd."type" AS "type",
	    pd."action" AS "action",
	    pd.status AS status,
	    pd.quantity AS quantity,
	    pd.campaign_id,
	    CASE WHEN pd.id IS NULL THEN NULL
	    	 WHEN s.campaign_id IN (
		      '822','6223','8103','8119','8129','8130','8180','8195','8202','8208')
	    	      AND s.created_at >= '2018-05-01'
	    	      AND pd."type" = 'photo'
	    	 THEN pd.quantity
		 ELSE 1 END AS reportback_volume,
	    pd."source" AS "source",
	    CASE WHEN pd."source" IS NULL THEN NULL
		 WHEN pd."source" ilike '%%sms%%' THEN 'sms'
		 ELSE 'web' END AS source_bucket,
	    COALESCE(rtv.created_at, tv.created_at, pd.created_at) AS created_at,
	    pd.url AS url,
	    pd.text,
	    CASE WHEN s."source" = 'importer-client'
		      AND pd."type" = 'share-social'
		      AND pd.created_at < s.created_at
		 THEN -1
		 ELSE pd.signup_id END AS signup_id,
	    CASE WHEN pd.id IS NULL THEN NULL
	    	 WHEN s.campaign_id IN (
		      '822','6223','8103','8119','8129','8130','8180','8195','8202','8208')
		      AND s.created_at >= '2018-05-01'
		      AND pd."type" = 'photo'
	    	 THEN 'voter-reg - ground'
	    	 ELSE CONCAT(pd."type", ' - ', pd."action") END AS post_class,
	    CASE WHEN pd.status IN ('accepted', 'pending')
	    	      AND s.campaign_id NOT IN (
		      '822','6223','8103','8119','8129','8130','8180','8195','8202','8208')
		      AND pd."type" NOT ILIKE 'vote%%'
	    	 THEN 1
	    	 WHEN pd.status IN ('accepted', 'confirmed', 'register-OVR', 'register-form')
	    	      AND (
		      	s.campaign_id IN (
	    	 	'822','6223','8103','8119','8129','8130','8180','8195','8202','8208')
		     	OR pd."type" ILIKE 'vote%%'
		      )
	    	 THEN 1
	    	 ELSE NULL END AS is_accepted,
	    pd.action_id,
	    a.reportback AS is_reportback,
	    a.civic_action,
	    a.scholarship_entry
    FROM ft_dosomething_rogue.posts pd
    INNER JOIN public.test_signups s
    	  ON pd.signup_id = s.id
    LEFT JOIN ft_dosomething_rogue.turbovote tv ON tv.post_id::bigint = pd.id::bigint
    LEFT JOIN
	(SELECT DISTINCT r.*,
		CASE WHEN r.started_registration < '2017-01-01'
		THEN r.started_registration + interval '4 year'
		ELSE r.started_registration END AS created_at
	FROM ft_dosomething_rogue.rock_the_vote r
	) rtv ON rtv.post_id::bigint = pd.id::bigint
    LEFT JOIN ft_dosomething_rogue.actions a
    	 ON pd.action_id = a.id
    WHERE pd.deleted_at IS NULL
	 AND pd."text" IS DISTINCT FROM 'test runscope upload'
)
;
CREATE UNIQUE INDEX ON public.posts (created_at, campaign_id, id);
CREATE INDEX ON public.posts (is_reportback, is_accepted, signup_id, id, post_class);
GRANT SELECT ON public.posts TO looker;
GRANT SELECT ON public.posts TO dsanalyst;

DROP MATERIALIZED VIEW IF EXISTS public.reportbacks;
CREATE MATERIALIZED VIEW public.reportbacks AS
    (
    SELECT
	pd.northstar_id,
	pd.id as post_id,
	pd.signup_id,
	pd.campaign_id,
	pd."action" as post_action,
	pd."type" as post_type,
	pd.status as post_status,
	pd.post_class,
	pd.created_at as post_created_at,
	pd.source as post_source,
	pd.source_bucket as post_source_bucket,
	pd.reportback_volume,
	pd.civic_action,
	pd.scholarship_entry
    FROM
	public.posts pd
    WHERE pd.id IN (
    	  SELECT min(id)
	  FROM public.posts p
	  WHERE p.is_reportback = 'true'
	  	 AND p.is_accepted = 1
	  GROUP BY p.northstar_id, p.campaign_id, p.signup_id, p.post_class, p.reportback_volume
	  )
);
CREATE UNIQUE INDEX ON public.reportbacks (post_id);
CREATE INDEX ON public.reportbacks (post_created_at, campaign_id, post_class, reportback_volume);
GRANT SELECT ON public.reportbacks TO looker;
GRANT SELECT ON public.reportbacks TO dsanalyst;
