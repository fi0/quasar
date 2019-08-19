SELECT
	b.event_id,
	b.event_source,
	b.event_datetime,
	b.event_name,
	b.event_type,
	b."host",
	b."path",
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
	p.url,
	p.campaign_id,
	p.modal_type
  FROM {{ ref('snowplow_base_event') }} b
  LEFT JOIN {{ ref('snowplow_payload_event') }} p 
  ON b.event_id = p.event_id