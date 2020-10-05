-- Combines attributes from the ft_snowplow.event and ft_snowplow.snowplow_event schemas
SELECT
	b.event_id,
	b.event_source,
	b.event_datetime,
	b.event_name,
	b.event_type,
	b."host",
	b."path",
    b.query_parameters,
	b.se_category,
	b.se_action,
	b.se_label,
	b.session_id,
	b.session_counter,
	b.browser_size,
	b.northstar_id,
	b.device_id,
	b.referrer_host,
	b.referrer_path,
	b.referrer_source,
	p.utm_source,
	p.utm_medium,
	p.utm_campaign,
	p.url AS clicked_link_url,
	p.campaign_id,
	p.page_id,
	p.block_id,
	p.group_id,
	p.modal_type,
	p.search_query,
	p.context_source,
	p.context_value
  FROM {{ ref('snowplow_base_event') }} b
  LEFT JOIN {{ ref('snowplow_payload_event') }} p
  ON b.event_id = p.event_id

{% if is_incremental() %}
  -- this filter will only be applied on an incremental run
  WHERE b.event_datetime >= (select max(sre.event_datetime) from {{this}} sre)
{% endif %}
