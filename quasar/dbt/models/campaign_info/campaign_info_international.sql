SELECT 
	c.id AS campaign_id,
	c.internal_title AS campaign_name,
	i.*
FROM :campaign_info_all i
LEFT JOIN :campaigns c ON i.campaign_run_id = c.campaign_run_id
WHERE campaign_language IS DISTINCT FROM 'en'
