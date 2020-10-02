
-- We are replicating all events from snowplow_raw_events just to add "campaign_name"
-- FIXME: Condense with snowplow_raw_events
SELECT DISTINCT ON (e.EVENT_ID)
    e.block_id,
    e.browser_size,
    e.campaign_id,
    i.campaign_name,
    e.clicked_link_url,
    e.context_source,
    e.context_value,
    e.device_id,
    e.event_datetime,
    e.event_id,
    CASE
        WHEN e.event_name IS NULL
        AND e.event_type = 'pv' THEN 'view'
        ELSE e.event_name
    END AS event_name,
    e.event_source,
    e.group_id,
    e."host",
    e.modal_type,
    e.northstar_id,
    e.page_id,
    e.utm_campaign AS page_utm_campaign,
    e.utm_medium AS page_utm_medium,
    e.utm_source AS page_utm_source,
    e."path",
    e.query_parameters,
    e.referrer_host,
    e.referrer_path,
    e.referrer_source,
    e.search_query,
    e.session_id
FROM {{ ref('snowplow_raw_events') }} e
LEFT JOIN {{ ref('campaign_info') }} i ON i.campaign_id = e.campaign_id::bigint

{% if is_incremental() %}
-- this filter will only be applied on an incremental run
WHERE event_datetime >= (select max(spe.event_datetime) from {{this}} spe)
{% endif %}
