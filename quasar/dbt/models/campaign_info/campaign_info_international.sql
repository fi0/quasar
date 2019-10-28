SELECT 
	c.campaign_id,
	c.campaign_name,
	i.*
FROM {{ ref('campaign_info_all') }} i
LEFT JOIN {{ ref('campaign_info') }} c ON i.campaign_run_id = c.campaign_run_id
WHERE campaign_language IS DISTINCT FROM 'en'
