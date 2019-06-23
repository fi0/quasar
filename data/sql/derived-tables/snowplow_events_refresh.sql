DROP TABLE IF EXISTS public.snowplow_base_event_stage;
CREATE TABLE public.snowplow_base_event_stage AS
(SELECT 
    event_id AS event_id,
    app_id AS event_source,
    collector_tstamp AS event_datetime,
    se_property AS event_name,
    "event" AS event_type,
    page_urlhost AS host,
    page_urlpath AS "path",
    se_category,
    se_action,
    se_label,
    domain_sessionid AS session_id,
    domain_sessionidx AS session_counter,
    dvce_type AS browser_size,
    user_id AS northstar_id,
    domain_userid AS device_id,
    refr_urlhost AS referrer_host,
    refr_urlpath AS referrer_path,
    refr_source AS referrer_source
  FROM ft_snowplow."event"
);
CREATE INDEX ON public.snowplow_base_event_stage (event_id);
GRANT SELECT ON public.snowplow_base_event_stage TO dsanalyst;

DROP INDEX IF EXISTS base_event_id;
TRUNCATE public.snowplow_base_event;
INSERT INTO public.snowplow_base_event
  SELECT * FROM public.snowplow_base_event_stage;
CREATE INDEX base_event_id ON public.snowplow_base_event (event_id);
DROP TABLE IF EXISTS public.snowplow_base_event_stage;

DROP TABLE IF EXISTS public.snowplow_payload_event_stage;
CREATE TABLE public.snowplow_payload_event_stage AS
(SELECT
    event_id,
    payload::jsonb #>> '{utmSource}' AS utm_source,
    payload::jsonb #>> '{utmMedium}' AS utm_medium,
    payload::jsonb #>> '{utmCampaign}' AS utm_campaign,
    payload::jsonb #>> '{url}' AS url,
    payload::jsonb #>> '{campaignId}' AS campaign_id,
    payload::jsonb #>> '{modalType}' AS modal_type
  FROM ft_snowplow.snowplow_event
);
CREATE INDEX ON public.snowplow_payload_event_stage (event_id);
GRANT SELECT ON public.snowplow_payload_event_stage TO dsanalyst;

DROP INDEX IF EXISTS payload_event_id;
TRUNCATE public.snowplow_payload_event;
INSERT INTO public.snowplow_payload_event
  SELECT * FROM public.snowplow_payload_event_stage;
CREATE INDEX payload_event_id ON public.snowplow_payload_event (event_id);
DROP TABLE IF EXISTS public.snowplow_payload_event_stage;

DROP TABLE IF EXISTS public.snowplow_raw_events_stage;
CREATE TABLE public.snowplow_raw_events_stage AS
(SELECT
	b.event_id,
	b.event_source,
	b.event_datetime,
	b.event_name,
	b.event_type,
	b."host",
	b."path",
	b.se_category,
	b.se_action,
	b.se_label,
	b.session_id,
	b.session_counter,
	b.browser_size,
	b.northstar_id,
	b.device_id,
	b.referrer_host,
	b.referrer_path,
	b.referrer_source,
	p.utm_source,
	p.utm_medium,
	p.utm_campaign,
	p.url,
	p.campaign_id,
	p.modal_type
  FROM public.snowplow_base_event b
  LEFT JOIN public.snowplow_payload_event p 
  ON b.event_id = p.event_id
);

DROP INDEX IF EXISTS event_index;
TRUNCATE public.snowplow_raw_events;
INSERT INTO public.snowplow_raw_events
  SELECT * FROM public.snowplow_raw_events_stage;
CREATE INDEX event_index ON public.snowplow_raw_events (event_id);
DROP TABLE IF EXISTS public.snowplow_raw_events_stage;
