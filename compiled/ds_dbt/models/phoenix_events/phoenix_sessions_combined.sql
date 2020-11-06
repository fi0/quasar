SELECT
    s.session_id,
    s.first_event_id,
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
FROM "quasar_prod_warehouse"."public"."snowplow_sessions" s

-- this filter will only be applied on an incremental run
WHERE s.landing_datetime >= (select max(psc.landing_datetime) from "quasar_prod_warehouse"."public"."phoenix_sessions_combined" psc)
