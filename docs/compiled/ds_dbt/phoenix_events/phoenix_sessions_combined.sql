SELECT 
    p.session_id,
    p.event_id,
    p.device_id,
    p.landing_datetime,
    p.end_datetime as ending_datetime,
    EXTRACT(EPOCH FROM (end_datetime - landing_datetime)) AS session_duration_seconds,
    NULL as num_pages_viewed,
    p.landing_page,
    NULL as exit_page,
    NULL as days_since_last_session
FROM public.puck_phoenix_sessions p
UNION ALL
SELECT
    s.session_id,
    s.event_id,
    s.device_id,
    s.landing_datetime,
    s.ending_datetime,
    s.session_duration_seconds,
    s.num_pages_viewed,
    s.landing_page,
    s.exit_page,
    s.days_since_last_session
FROM "postgres"."rpacas"."snowplow_sessions" s