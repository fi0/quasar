SELECT
    event_id,
    payload::jsonb #>> '{utmSource}' AS utm_source,
    payload::jsonb #>> '{utmMedium}' AS utm_medium,
    payload::jsonb #>> '{utmCampaign}' AS utm_campaign,
    payload::jsonb #>> '{url}' AS url,
    payload::jsonb #>> '{campaignId}' AS campaign_id,
    payload::jsonb #>> '{modalType}' AS modal_type,
    payload::jsonb #>> '{searchQuery}' AS search_query,
    payload::jsonb #>> '{contextSource}' AS context_source,
    payload::jsonb #>> '{value}' AS context_value,
    _fivetran_synced AS ft_timestamp
FROM {{ env_var('FT_SNOWPLOW') }}.snowplow_event

{% if is_incremental() %}
-- this filter will only be applied on an incremental run
WHERE collector_tstamp.event_datetime >= {{ var('run_interval') }}
{% endif %}