SELECT
	c.id AS campaign_id,
	c.internal_title AS campaign_name,
	i.*
FROM {{ source('campaign_info_historical', 'campaign_info_ashes_snapshot') }} i
LEFT JOIN {{ source('rogue', 'campaigns') }} c ON i.campaign_run_id = c.campaign_run_id
WHERE campaign_language IS DISTINCT FROM 'en'
