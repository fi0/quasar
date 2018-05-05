DROP MATERIALIZED VIEW IF EXISTS public.path_campaign_lookup;
DROP MATERIALIZED VIEW IF EXISTS public.phoenix_next_events; 
DROP MATERIALIZED VIEW IF EXISTS public.phoenix_next_sessions; 
DROP MATERIALIZED VIEW IF EXISTS public.device_northstar_crosswalk;

CREATE MATERIALIZED VIEW public.path_campaign_lookup AS 
	(
	SELECT 
		max(camps.campaign_id) AS campaign_id,
		camps.campaign_name
	FROM 
		(SELECT DISTINCT 
			COALESCE(
				NULLIF(regexp_replace(dat.legacycampaignid_s, '[^0-9.]','','g'), ''),
				NULLIF(regexp_replace(dat.campaignid_s, '[^0-9.]','','g'), '')
				)::NUMERIC AS campaign_id,
			(regexp_split_to_array(page.path_s, E'\/'))[4] AS campaign_name
			FROM heroku_wzsf6b3z.events_meta meta
			LEFT JOIN heroku_wzsf6b3z.events_data dat ON dat.did = meta.did
			LEFT JOIN heroku_wzsf6b3z.events_page page ON page.did = meta.did
			WHERE dat.campaignid_s IS NOT NULL
			) camps
	GROUP BY camps.campaign_name
	)
;

CREATE MATERIALIZED VIEW public.phoenix_next_events AS 
	(SELECT 
		meta.did::VARCHAR AS event_id,
		meta.timestamp_d AS ts,
		event.name_s AS event_name,
		event.source_s AS event_source,
		page.path AS path,
		page.host AS host,
		page.href AS href, 
		page_q.utm_source_s AS page_utm_source,
		page_q.utm_medium_s AS page_utm_medium,
		page_q.utm_campaign_s AS page_utm_campaign,
		dat.parentsource_s AS parent_source, 
		COALESCE(dat.campaign_id::varchar, lookup.campaign_id::varchar) AS campaign_id,
		page.campaign_name,
		dat.source_s AS source,
		dat.link_s AS link,
		dat.modaltype_s AS modal_type,
		dat.variant_s AS variant,
		sdata.text_s AS source_data_text,
		page.session_id AS session_id,
		use.northstarid_s,
		brow.size_s AS device_size
	FROM heroku_wzsf6b3z.events_meta meta
	LEFT JOIN heroku_wzsf6b3z.events_event event ON event.did = meta.did
	LEFT JOIN 
		(SELECT 
			edat.did,
			edat.parentsource_s,
			edat.source_s,
			edat.link_s,
			edat.modaltype_s,
			edat.variant_s,
			COALESCE(
				NULLIF(regexp_replace(edat.legacycampaignid_s, '[^0-9.]','','g'), ''),
				NULLIF(regexp_replace(edat.campaignid_s, '[^0-9.]','','g'), '')
				) AS campaign_id
		FROM heroku_wzsf6b3z.events_data edat 
		) dat ON dat.did = meta.did
	LEFT JOIN heroku_wzsf6b3z.events_data_sourcedata sdata ON sdata.did = meta.did
	LEFT JOIN 
		(SELECT 
			p.did,
			p.path_s AS path,
			p.host_s AS host,
			p.href_s AS href, 
			p.sessionid_s AS session_id,
			(regexp_split_to_array(p.path_s, E'\/'))[4] AS campaign_name
		FROM heroku_wzsf6b3z.events_page p) page ON page.did = meta.did
	LEFT JOIN path_campaign_lookup lookup ON page.campaign_name = lookup.campaign_name
	LEFT JOIN heroku_wzsf6b3z.events_page_query page_q ON page_q.did = meta.did 
	LEFT JOIN heroku_wzsf6b3z.events_user use ON use.did = meta.did
	LEFT JOIN heroku_wzsf6b3z.events_browser brow ON brow.did = meta.did
	)
;	
	
CREATE MATERIALIZED VIEW public.phoenix_next_sessions AS 
	(SELECT
		page.sessionid_s AS session_id,  
		max(use.deviceid_s) AS device_id,
		min(COALESCE(page.landingtimestamp_d, 
			(CASE WHEN page.landingtimestamp_s = 'null' THEN NULL ELSE page.landingtimestamp_s END)::bigint
			)::bigint) AS landing_ts,
		max(refer.path_s) AS referrer_path,
		max(refer.host_s) AS referrer_host,
		max(refer.href_s) AS referrer_href,		
		max(ref_q.from_session_s),
		max(ref_q.source_s) AS referrer_source,
		max(ref_q.utm_medium_s) AS referrer_utm_medium,
		max(ref_q.utm_source_s) AS referrer_utm_source,
		max(ref_q.utm_campaign_s) AS referrer_utm_campaign
	FROM heroku_wzsf6b3z.events_page page
	LEFT JOIN 
		(SELECT 
			page_temp.sessionid_s,
			max(use_temp.deviceid_s::bigint) AS deviceid_s
		FROM heroku_wzsf6b3z.events_page page_temp
		LEFT JOIN heroku_wzsf6b3z.events_user use_temp ON page_temp.did = use_temp.did
		GROUP BY page_temp.sessionid_s) use ON page.sessionid_s = use.sessionid_s
	LEFT JOIN heroku_wzsf6b3z.events_page_referrer refer ON refer.did = page.did
	LEFT JOIN heroku_wzsf6b3z.events_page_referrer_query ref_q ON ref_q.did = page.did
	GROUP BY page.sessionid_s)
;

CREATE MATERIALIZED VIEW public.device_northstar_crosswalk AS 
	(SELECT 
		nsids.deviceid_s,
		nsids.northstarid_s,
		counts.proportion
	FROM 
		(SELECT 
			dis.deviceid_s,
			1/count(dis.deviceid_s)::FLOAT AS proportion
		FROM 
			(SELECT DISTINCT 
			    u.deviceid_s,
			    u.northstarid_s
			  FROM heroku_wzsf6b3z.events_user u 
			  WHERE u.northstarid_s IS NOT NULL) dis
		GROUP BY dis.deviceid_s) counts
	LEFT JOIN 
		(SELECT DISTINCT 
		    u.deviceid_s,
		    u.northstarid_s
		 FROM heroku_wzsf6b3z.events_user u 
		 WHERE u.northstarid_s IS NOT NULL) nsids
		ON nsids.deviceid_s = counts.deviceid_s
	);

GRANT SELECT ON public.phoenix_next_sessions TO jjensen;
GRANT SELECT ON public.phoenix_next_sessions TO public;
GRANT SELECT ON public.phoenix_next_sessions TO looker;
GRANT SELECT ON public.phoenix_next_sessions TO shasan;
GRANT SELECT ON public.phoenix_next_sessions TO jli;
GRANT SELECT ON public.phoenix_next_events TO public;
GRANT SELECT ON public.phoenix_next_events TO jjensen;
GRANT SELECT ON public.phoenix_next_events TO looker;
GRANT SELECT ON public.phoenix_next_events TO shasan;
GRANT SELECT ON public.phoenix_next_events TO jli;
GRANT SELECT ON public.device_northstar_crosswalk TO public;
GRANT SELECT ON ALL tables IN SCHEMA public TO jjensen;
GRANT SELECT ON ALL tables IN SCHEMA public TO looker;
GRANT SELECT ON ALL tables IN SCHEMA public TO shasan;
GRANT SELECT ON ALL tables IN SCHEMA public TO jli;
GRANT USAGE ON SCHEMA heroku_wzsf6b3z TO jjensen;
GRANT USAGE ON SCHEMA heroku_wzsf6b3z TO shasan;
GRANT USAGE ON SCHEMA heroku_wzsf6b3z TO looker;
GRANT USAGE ON SCHEMA heroku_wzsf6b3z TO jli;
GRANT SELECT ON ALL tables IN SCHEMA heroku_wzsf6b3z TO jjensen;
GRANT SELECT ON ALL tables IN SCHEMA heroku_wzsf6b3z TO shasan;
GRANT SELECT ON ALL tables IN SCHEMA heroku_wzsf6b3z TO looker;
GRANT SELECT ON ALL tables IN SCHEMA heroku_wzsf6b3z TO jli;