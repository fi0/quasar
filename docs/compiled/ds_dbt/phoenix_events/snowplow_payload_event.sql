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
    _fivetran_synced AS ft_timestamp
  FROM ft_snowplow.snowplow_event