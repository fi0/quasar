SELECT
    e.event_id,
    e.event_datetime,
    CASE WHEN e.event_name IS NULL
    AND e.event_type = 'pv'
    THEN 'view' ELSE e.event_name END AS event_name,
    e.event_source,
    e."path",
    e."host",
    e.query_parameters,
    e.clicked_link_url,
    e.utm_source AS page_utm_source,
    e.utm_medium AS page_utm_medium,
    e.utm_campaign AS page_utm_campaign,
    e.referrer_host,
    e.referrer_path,
    e.referrer_source,
    e.campaign_id,
    i.campaign_name,
    e.modal_type,
    e.search_query,
    e.context_source,
    e.session_id,
    e.browser_size,
    e.northstar_id,
    e.device_id
FROM "quasar_prod_warehouse"."public"."snowplow_raw_events" e
LEFT JOIN "quasar_prod_warehouse"."public"."campaign_info" i ON i.campaign_id = e.campaign_id::bigint