SELECT
    p.event_id,
    p.event_datetime,
    p.event_name,
    p.event_source,
    p."path",
    p."host",
    NULL AS query_parameters,
    NULL AS clicked_link_url,
    p.page_utm_source,
    p.page_utm_medium,
    p.page_utm_campaign,
    p.referrer_host,
    p.referrer_path,
    p.referrer_source,
    p.campaign_id,
    p.campaign_name,
    p.modal_type,
    NULL AS search_query,
    NULL AS context_source,
    p.session_id,
    p.browser_size,
    p.northstar_id,
    p.device_id
FROM
    public.puck_phoenix_events p
UNION ALL
SELECT
    s.event_id,
    s.event_datetime,
    s.event_name,
    s.event_source,
    s."path",
    s."host",
    s.query_parameters,
    s.clicked_link_url,
    s.page_utm_source,
    s.page_utm_medium,
    s.page_utm_campaign,
    s.referrer_host,
    s.referrer_path,
    s.referrer_source,
    s.campaign_id,
    s.campaign_name,
    s.modal_type,
    s.search_query,
    s.context_source,
    s.session_id,
    s.browser_size,
    s.northstar_id,
    s.device_id
FROM
    {{ ref('snowplow_phoenix_events') }} s

