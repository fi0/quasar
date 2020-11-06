SELECT
    event_id,
    payload::jsonb #>> '{name}' AS event_name,
    payload::jsonb #>> '{utmSource}' AS utm_source,
    payload::jsonb #>> '{utmMedium}' AS utm_medium,
    payload::jsonb #>> '{utmCampaign}' AS utm_campaign,
    payload::jsonb #>> '{url}' AS url,
    payload::jsonb #>> '{campaignId}' AS campaign_id,
    payload::jsonb #>> '{pageId}' AS page_id,
    payload::jsonb #>> '{blockId}' AS block_id,
    payload::jsonb #>> '{groupId}' AS group_id,
    payload::jsonb #>> '{modalType}' AS modal_type,
    payload::jsonb #>> '{searchQuery}' AS search_query,
    payload::jsonb #>> '{contextSource}' AS context_source,
    payload::jsonb #>> '{value}' AS context_value,
    _fivetran_synced AS ft_timestamp
FROM "quasar_prod_warehouse"."ft_snowplow"."snowplow_event"


-- this filter will only be applied on an incremental run
WHERE _fivetran_synced >= (select max(spe.ft_timestamp) from "quasar_prod_warehouse"."public"."snowplow_payload_event" spe)
