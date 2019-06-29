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

DROP TABLE IF EXISTS public.snowplow_phoenix_events_stage;
CREATE TABLE public.snowplow_phoenix_events_stage AS (
    SELECT
        e.event_id,
        e.event_datetime,
        CASE WHEN e.event_name IS NULL
        AND e.event_type = 'pv'
        THEN 'view' ELSE e.event_name END AS event_name,
        e.event_source,
        e."path",
        e."host",
        e.utm_source AS page_utm_source,
        e.utm_medium AS page_utm_medium,
        e.utm_campaign AS page_utm_campaign,
        e.campaign_id,
        i.campaign_name,
        e.modal_type,
        e.session_id,
        e.browser_size,
        e.northstar_id,
        e.device_id
    FROM public.snowplow_raw_events e
    LEFT JOIN public.campaign_info i ON i.campaign_id = e.campaign_id::bigint
);

DROP INDEX IF EXISTS spe_unique;
DROP INDEX IF EXISTS spe_session_id;
TRUNCATE public.snowplow_phoenix_events;
INSERT INTO public.snowplow_phoenix_events
  SELECT * FROM public.snowplow_phoenix_events_stage;
CREATE UNIQUE INDEX spe_unique ON public.snowplow_phoenix_events (event_datetime, event_name, event_id);
CREATE INDEX spe_session_id ON public.snowplow_phoenix_events (session_id);
DROP TABLE IF EXISTS public.snowplow_phoenix_events_stage;

DROP TABLE IF EXISTS public.snowplow_sessions_stage;
CREATE TABLE public.snowplow_sessions_stage AS (
    WITH sessions AS (
    SELECT
        session_id,
        min(device_id) AS device_id,
        min(event_datetime) AS landing_datetime,
        max(event_datetime) AS ending_datetime,
        date_part(
        'seconds', max(event_datetime) - min(event_datetime)
        ) AS session_duration_seconds,
        count(DISTINCT CASE WHEN event_name = 'view' THEN "path" END) AS num_pages_viewed
    FROM snowplow_phoenix_events
    GROUP BY session_id
    ),
    entry_exit_pages AS (
    SELECT DISTINCT
        session_id,
        first_value("path") OVER (PARTITION BY session_id ORDER BY event_datetime 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS landing_page,
        last_value("path") OVER (PARTITION BY session_id ORDER BY event_datetime 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS exit_page
    FROM snowplow_phoenix_events
    ),
    time_between_sessions AS (
    SELECT DISTINCT
        device_id,
        session_id,
        LAG(ending_datetime) OVER (PARTITION BY device_id ORDER BY landing_datetime
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS prev_session_endtime
    FROM sessions
    )
    SELECT
    s.session_id,
    s.device_id,
    s.landing_datetime,
    s.ending_datetime,
    s.session_duration_seconds,
    s.num_pages_viewed,
    p.landing_page,
    p.exit_page,
    date_part('day', s.landing_datetime - t.prev_session_endtime) AS days_since_last_session
    FROM sessions s
    LEFT JOIN entry_exit_pages p
    ON p.session_id = s.session_id
    LEFT JOIN time_between_sessions t
    ON t.session_id = s.session_id
);

DROP INDEX IF EXISTS sps_landing;
TRUNCATE public.snowplow_sessions;
INSERT INTO public.snowplow_sessions
  SELECT * FROM public.snowplow_sessions_stage;
CREATE INDEX sps_landing ON public.snowplow_sessions (landing_datetime, landing_page);
DROP TABLE IF EXISTS public.snowplow_sessions_stage;