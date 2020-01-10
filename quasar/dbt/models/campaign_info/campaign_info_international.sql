SELECT 
	c.id AS campaign_id,
	c.internal_title AS campaign_name,
	i.*
FROM {{ env_var('CAMPAIGN_INFO_ASHES_SNAPSHOT') }} i
LEFT JOIN {{ env_var('FT_ROGUE') }}.campaigns c ON i.campaign_run_id = c.campaign_run_id
WHERE campaign_language IS DISTINCT FROM 'en'
