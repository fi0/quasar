SELECT DISTINCT ON(p.event_datetime, p.event_name, p.event_id)
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
    NULL AS page_id,
    NULL AS block_id,
    NULL AS group_id,
    p.modal_type,
    NULL AS search_query,
    NULL AS context_source,
    NULL AS context_value,
    p.session_id,
    p.browser_size,
    p.northstar_id,
    p.device_id
FROM
    {{ source('web_events_historical', 'phoenix_events') }} p
{% if is_incremental() %}
-- this filter will only be applied on an incremental run
    WHERE p.event_datetime >= (SELECT max(pec.event_datetime) FROM {{this}} pec)
{% endif %}
UNION ALL
SELECT DISTINCT ON(s.event_datetime, s.event_name, s.event_id)
    s.event_id,
    s.event_datetime,
    s.event_name,
    s.event_source,
    s."path",
    s."host",
    s.query_parameters,
    s.clicked_link_url,
    s.utm_source as page_utm_source,
    s.utm_medium as page_utm_medium,
    s.utm_campaign as page_utm_campaign,
    s.referrer_host,
    s.referrer_path,
    s.referrer_source,
    s.campaign_id,
    s.campaign_name,
    s.page_id,
    s.block_id,
    s.group_id,
    s.modal_type,
    s.search_query,
    s.context_source,
    s.context_value,
    s.session_id,
    s.browser_size,
    s.northstar_id,
    s.device_id
FROM
    {{ ref('snowplow_raw_events') }} s
{% if is_incremental() %}
-- this filter will only be applied on an incremental run
WHERE s.event_datetime >= (select max(pec.event_datetime) from {{this}} pec)
{% endif %}
