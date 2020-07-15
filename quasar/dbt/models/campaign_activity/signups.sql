SELECT
    sd.northstar_id AS northstar_id,
    sd.id AS id,
    sd.campaign_id AS campaign_id,
    sd.campaign_run_id AS campaign_run_id,
    sd.why_participated AS why_participated,
    sd."source" AS "source",
    sd.details,
    sd.referrer_user_id,
    sd.group_id,
	CASE WHEN sd."source" = 'niche' THEN 'niche'
	     WHEN sd."source" ilike '%sms%' THEN 'sms'
	     WHEN sd."source" in ('rock-the-vote', 'turbovote') THEN 'voter-reg'
	     ELSE 'web' END AS source_bucket,
    sd.created_at AS created_at,
    sd.source_details,
    CASE 
		WHEN source_details ILIKE '%\}'
		THEN (CAST(source_details as json) ->> 'utm_medium') 
		ELSE NULL END AS utm_medium,
	CASE 
		WHEN source_details ILIKE '%\}'
		THEN (CAST(source_details as json) ->> 'utm_source')
		ELSE NULL END AS utm_source,
	CASE 
		WHEN source_details ILIKE '%\}'
		THEN (CAST(source_details as json) ->> 'utm_campaign')
		ELSE NULL END AS utm_campaign
FROM {{ source('rogue', 'signups') }} sd
WHERE sd._fivetran_deleted = 'false'
AND sd.deleted_at IS NULL
AND sd."source" IS DISTINCT FROM 'rogue-oauth'
AND sd.why_participated IS DISTINCT FROM 'Testing from Ghost Inspector!'
