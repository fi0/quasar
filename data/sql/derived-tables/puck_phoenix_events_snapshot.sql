CREATE TABLE public.puck_phoenix_events AS (
SELECT DISTINCT event_id, 
                puck_id, 
                event_datetime,
                new_event_name,
                event_source, 
                "path", 
                "host", 
                href, 
                page_utm_source, 
                page_utm_medium, 
                page_utm_campaign,
                parent_source,
                campaign_id,
                campaign_name,
                "source",
                link,
                modal_type,
                variant,
                source_data_text,
                session_id,
                browser_size,
                northstar_id,
                device_id                
FROM public.phoenix_events
WHERE event_datetime < '06-26-2019 00:00:00'
);
ALTER TABLE public.puck_phoenix_events RENAME COLUMN new_event_name TO event_name;
CREATE UNIQUE INDEX ON public.puck_phoenix_events (event_id, event_name, ts, event_datetime, northstar_id, session_id);


CREATE TABLE public.puck_phoenix_sessions AS (
SELECT * 
FROM public.phoenix_sessions
WHERE landing_datetime < '06-26-2019 00:00:00'
);
CREATE UNIQUE INDEX ON public.puck_phoenix_sessions (session_id, device_id, landing_ts, landing_datetime);