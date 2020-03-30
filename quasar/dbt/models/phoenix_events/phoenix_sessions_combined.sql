SELECT 
    p.session_id,
    p.event_id,
    p.device_id,
    p.landing_datetime,
    p.end_datetime as ending_datetime,
    p.referrer_host as session_referrer_host,
    p.utm_source as session_utm_source,
    p.utm_campaign as session_utm_campaign,
    EXTRACT(EPOCH FROM (end_datetime - landing_datetime)) AS session_duration_seconds,
    NULL as num_pages_viewed,
    p.landing_page,
    NULL as exit_page,
    NULL as days_since_last_session
FROM {{ source('web_events_historical', 'phoenix_sessions') }} p
UNION ALL
SELECT
    s.session_id,
    s.event_id,
    s.device_id,
    s.landing_datetime,
    s.ending_datetime,
    s.session_referrer_host,
    s.session_utm_source,
    s.session_utm_campaign,
    s.session_duration_seconds,
    s.num_pages_viewed,
    s.landing_page,
    s.exit_page,
    s.days_since_last_session
FROM {{ ref('snowplow_sessions') }} s

