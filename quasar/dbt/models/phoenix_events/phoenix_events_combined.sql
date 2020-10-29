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
