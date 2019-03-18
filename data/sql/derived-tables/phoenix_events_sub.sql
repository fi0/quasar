DROP MATERIALIZED VIEW IF EXISTS :path_campaign_lookup CASCADE;
CREATE MATERIALIZED VIEW :path_campaign_lookup AS 
	(
	SELECT 
		max(camps.campaign_id) AS campaign_id,
		camps.campaign_name
	FROM 
		(SELECT DISTINCT 
			COALESCE(
				NULLIF(regexp_replace(e."data" #>> '{campaignId}', '[^0-9.]','','g'), ''),
				NULLIF(regexp_replace(e."data" #>> '{legacyCampaignId}', '[^0-9.]','','g'), '')
		 		) AS campaign_id,
			(regexp_split_to_array(e."page" #>> '{path}', E'\/'))[4] AS campaign_name
			FROM :events e
			WHERE e."data" #>> '{campaignId}' IS NOT NULL 
				OR e."data" #>> '{legacyCampaignId}' IS NOT NULL 
			) camps
	INNER JOIN campaign_info i ON i.campaign_id::varchar = camps.campaign_id
	GROUP BY camps.campaign_name
	)
;
GRANT SELECT ON :path_campaign_lookup TO looker;
GRANT SELECT ON :path_campaign_lookup TO dsanalyst;

DROP MATERIALIZED VIEW IF EXISTS :phoenix_utms CASCADE;
CREATE MATERIALIZED VIEW :phoenix_utms AS (
	SELECT 
		e."page" #>> '{sessionId}' AS session_id,
		max(e."page" #> '{query}' ->> 'utm_source') AS utm_source,
		max(e."page" #> '{query}' ->> 'utm_medium') AS utm_medium,
		max(e."page" #> '{query}' ->> 'utm_campaign') AS utm_campaign
	FROM :events e
	GROUP BY e."page" #>> '{sessionId}'
	);
CREATE INDEX ON :phoenix_utms (session_id);

DROP MATERIALIZED VIEW IF EXISTS :phoenix_events CASCADE;
CREATE MATERIALIZED VIEW :phoenix_events AS (
	SELECT DISTINCT
		e._id AS event_id,
		e.meta #>> '{id}' AS puck_id,
		to_timestamp((e.meta #>> '{timestamp}')::numeric/1000) AS event_datetime,
		(e.meta #>> '{timestamp}')::numeric AS ts,
		COALESCE((CASE 
				  WHEN enames_old.old_name IS NOT NULL 
				  THEN enames_old.old_name
				  ELSE enames_new.old_name END), 
				  e.event #>> '{name}')
			AS event_name,
		COALESCE(enames_new.new_name, enames_old.new_name, e.event #>> '{name}') AS new_event_name,
		e.event #>> '{source}' AS event_source,
		e.page #>> '{path}' AS "path",
		e.page #>> '{host}' AS host,
		e.page #>> '{href}' AS href,
		utms.utm_source AS page_utm_source,
		utms.utm_medium AS page_utm_medium,
		utms.utm_campaign AS page_utm_campaign,
		e."data" #>> '{parentSource}' AS parent_source,
		COALESCE(dat.campaign_id::varchar, lookup.campaign_id::varchar) AS campaign_id,
		CASE WHEN e.page #>> '{href}' ILIKE '%%password/reset%%' THEN NULL ELSE page.campaign_name END AS campaign_name,
		e."data" #>> '{source}' AS "source",
		e."data" #>> '{link}' AS link,
		e."data" #>> '{modalType}' AS modal_type,
		e."data" #>> '{variant}' AS variant,
		e."data" #> '{sourceData}' ->> 'text' AS source_data_text,
		e.page #>> '{sessionId}' AS session_id,
		e.browser #>> '{size}' AS browser_size,
		e.user #>> '{northstarId}' AS northstar_id,
		e.user #>> '{deviceId}' AS device_id
	FROM :events e
	LEFT JOIN :event_lookup enames_old ON e.event #>> '{name}' = enames_old.old_name
	LEFT JOIN :event_lookup enames_new ON e.event #>> '{name}' = enames_new.new_name
	LEFT JOIN 
		(SELECT 
			edat._id AS object_id,
			COALESCE(
				NULLIF(regexp_replace(edat."data" #>> '{legacyCampaignId}', '[^0-9.]','','g'), ''),
				NULLIF(regexp_replace(edat."data" #>> '{campaignId}', '[^0-9.]','','g'), '')
		 		) AS campaign_id
		FROM :events edat
		WHERE edat."data" IS NOT NULL) dat ON e._id = dat.object_id
	LEFT JOIN 
		(SELECT 
			p._id AS object_id,
			(regexp_split_to_array(p.page #>> '{path}', E'\/'))[4] AS campaign_name 
		FROM :events p) page ON page.object_id = e._id
	LEFT JOIN :path_campaign_lookup lookup ON page.campaign_name = lookup.campaign_name
	LEFT JOIN :phoenix_utms utms ON utms.session_id = e.page #>> '{sessionId}'
) 
;
CREATE UNIQUE INDEX ON :phoenix_events (event_id, event_name, ts, event_datetime, northstar_id, session_id);
GRANT SELECT ON :phoenix_events TO looker;
GRANT SELECT ON :phoenix_events TO dsanalyst;
