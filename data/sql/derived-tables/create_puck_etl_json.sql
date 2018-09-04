DROP MATERIALIZED VIEW IF EXISTS public.device_northstar_crosswalk;
DROP MATERIALIZED VIEW IF EXISTS public.phoenix_sessions; 
DROP MATERIALIZED VIEW IF EXISTS public.phoenix_events; 
DROP MATERIALIZED VIEW IF EXISTS public.path_campaign_lookup;

CREATE MATERIALIZED VIEW public.path_campaign_lookup AS 
	(
	SELECT 
		max(camps.campaign_id) AS campaign_id,
		camps.campaign_name
	FROM 
		(SELECT DISTINCT 
			COALESCE(
				NULLIF(regexp_replace(e.records #>> '{data,campaignId}', '[^0-9.]','','g'), ''),
				NULLIF(regexp_replace(e.records #>> '{data,legacyCampaignId}', '[^0-9.]','','g'), '')
		 		) AS campaign_id,
			(regexp_split_to_array(e.records #>> '{page,path}', E'\/'))[4] AS campaign_name
			FROM puck.events_json e
			WHERE e.records #>> '{data,campaignId}' IS NOT NULL 
				OR e.records #>> '{data,legacyCampaignId}' IS NOT NULL 
			) camps
	GROUP BY camps.campaign_name
	)
;

CREATE MATERIALIZED VIEW puck.phoenix_utms AS (
	SELECT 
		e.records #>> '{page,sessionId}' AS session_id,
		max(e.records #> '{page,query}' ->> 'utm_source') AS utm_source,
		max(e.records #> '{page,query}' ->> 'utm_medium') AS utm_medium,
		max(e.records #> '{page,query}' ->> 'utm_campaign') AS utm_campaign
	FROM puck.events_json e
	GROUP BY e.records #>> '{page,sessionId}'
	);
	
CREATE INDEX utm_index ON puck.phoenix_utms (session_id);

CREATE MATERIALIZED VIEW public.phoenix_events AS (
	SELECT 
		e.records #>> '{_id,$oid}' AS event_id,
		e.records #>> '{meta,id}' AS puck_id,
		to_timestamp((e.records #>> '{meta,timestamp}')::bigint/1000) AS event_datetime,
		(e.records #>> '{meta,timestamp}')::bigint AS ts,
		e.records #>> '{event,name}' AS event_name,
		e.records #>> '{event,source}' AS event_source,
		e.records #>> '{page,path}' AS "path",
		e.records #>> '{page,host}' AS host,
		e.records #>> '{page,href}' AS href,
		utms.utm_source AS page_utm_source,
		utms.utm_medium AS page_utm_medium,
		utms.utm_campaign AS page_utm_campaign,
		e.records #>> '{data,parentSource}' AS parent_source,
		COALESCE(dat.campaign_id::varchar, lookup.campaign_id::varchar) AS campaign_id,
		CASE WHEN e.records #>> '{page,href}' ILIKE '%password/reset%' THEN NULL ELSE page.campaign_name END AS campaign_name,
		e.records #>> '{data,source}' AS "source",
		e.records #>> '{data,link}' AS link,
		e.records #>> '{data,modalType}' AS modal_type,
		e.records #>> '{data,variant}' AS variant,
		e.records #> '{data,sourceData}' ->> 'text' AS source_data_text,
		e.records #>> '{page,sessionId}' AS session_id,
		e.records #>> '{browser,size}' AS browser_size,
		e.records #>> '{user,northstarId}' AS northstar_id
	FROM puck.events_json e
	LEFT JOIN 
		(SELECT 
			edat.records #>> '{_id,$oid}' AS object_id,
			COALESCE(
				NULLIF(regexp_replace(edat.records #>> '{data,legacyCampaignId}', '[^0-9.]','','g'), ''),
				NULLIF(regexp_replace(edat.records #>> '{data,campaignId}', '[^0-9.]','','g'), '')
		 		) AS campaign_id
		FROM puck.events_json edat
		WHERE edat.records #> '{data}' IS NOT NULL) dat ON e.records #>> '{_id,$oid}' = dat.object_id
	LEFT JOIN 
		(SELECT 
			p.records #>> '{_id,$oid}' AS object_id,
			(regexp_split_to_array(p.records #>> '{page,path}', E'\/'))[4] AS campaign_name 
		FROM puck.events_json p) page ON page.object_id = e.records #>> '{_id,$oid}'
	LEFT JOIN public.path_campaign_lookup lookup ON page.campaign_name = lookup.campaign_name
	LEFT JOIN puck.phoenix_utms utms ON utms.session_id = e.records #>> '{page,sessionId}'
) 
;

CREATE MATERIALIZED VIEW phoenix_sessions AS (
	SELECT 
		e.records #>> '{page,sessionId}' AS session_id,
		max(e.records #>> '{user,deviceId}') AS device_id,
		min(
			CASE WHEN 
				e.records #>> '{page,landingTimestamp}' = 'null' 
				THEN e.records #>> '{meta,timestamp}' 
				ELSE e.records #>> '{page,landingTimestamp}' END
			)::bigint AS landing_ts,
		min(
			to_timestamp(
			(CASE WHEN 
				e.records #>> '{page,landingTimestamp}' = 'null' 
				THEN e.records #>> '{meta,timestamp}' 
				ELSE e.records #>> '{page,landingTimestamp}' 
				END)::bigint/1000)
			)  AS landing_datetime,
		max(e.records #> '{page,referrer}' ->> 'path') AS referrer_path,
		max(e.records #> '{page,referrer}' ->> 'host') AS referrer_host,
		max(e.records #> '{page,referrer}' ->> 'href') AS referrer_href,
		max(e.records #> '{page,referrer}' -> 'query' ->> 'from_session') AS from_session,
		max(e.records #> '{page,referrer}' -> 'query' ->> 'source') AS referrer_source,
		max(COALESCE(
			e.records #> '{page,referrer}' -> 'query' ->> 'utm_source',
			e.records #> '{page,referrer}' -> 'query' ->> 'amp;utm_source'
			)) AS referrer_utm_source,
		max(COALESCE(
			e.records #> '{page,referrer}' -> 'query' ->> 'utm_medium',
			e.records #> '{page,referrer}' -> 'query' ->> 'amp;utm_medium'
			)) AS referrer_utm_medium,
		max(COALESCE(
			e.records #> '{page,referrer}' -> 'query' ->> 'utm_campaign',
			e.records #> '{page,referrer}' -> 'query' ->> 'amp;utm_campaign'
			)) AS referrer_utm_campaign
	FROM puck.events_json e 
	GROUP BY e.records #>> '{page,sessionId}'
) ;

CREATE MATERIALIZED VIEW public.device_northstar_crosswalk AS 
	(SELECT 
		nsids.device_id,
		nsids.northstar_id,
		counts.proportion
	FROM 
		(SELECT 
			dis.device_id,
			1/count(dis.device_id)::FLOAT AS proportion
		FROM 
			(SELECT DISTINCT 
			    e.records #>> '{user,deviceId}' AS device_id,
			    e.records #>> '{user,northstarId}' AS northstar_id
			  FROM puck.events_json e 
			  WHERE e.records #>> '{user,northstarId}' IS NOT NULL) dis
		GROUP BY dis.device_id) counts
	LEFT JOIN 
		(SELECT DISTINCT 
		    e.records #>> '{user,deviceId}' AS device_id,
		    e.records #>> '{user,northstarId}' AS northstar_id
		 FROM puck.events_json e  
		 WHERE e.records #>> '{user,northstarId}' IS NOT NULL) nsids
		ON nsids.device_id = counts.device_id
	);

CREATE INDEX pe_indices ON phoenix_events (event_id, event_name, ts, event_datetime, northstar_id, session_id);
CREATE INDEX ps_indices ON phoenix_sessions (session_id, device_id, landing_ts, landing_datetime);
CREATE INDEX dnc_indices ON device_northstar_crosswalk (northstar_id, device_id);

GRANT SELECT ON public.phoenix_sessions TO public;
GRANT SELECT ON public.phoenix_sessions TO looker;
GRANT SELECT ON public.phoenix_sessions TO dsanalyst;
GRANT SELECT ON public.phoenix_events TO public;
GRANT SELECT ON public.phoenix_events TO looker;
GRANT SELECT ON public.phoenix_events TO dsanalyst;
GRANT SELECT ON public.device_northstar_crosswalk TO public;
GRANT SELECT ON public.device_northstar_crosswalk TO looker;
GRANT SELECT ON public.device_northstar_crosswalk TO dsanalyst;
GRANT SELECT ON public.path_campaign_lookup TO public;
GRANT SELECT ON public.path_campaign_lookup TO looker;
GRANT SELECT ON public.path_campaign_lookup TO dsanalyst;