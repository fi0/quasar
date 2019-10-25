SELECT 
	c.id AS campaign_id,
	c.internal_title AS campaign_name,
	i.*
FROM "postgres"."rpacas_ft_dosomething_rogue_qa"."campaign_info_all" i
LEFT JOIN "postgres"."rpacas"."campaign_info" c ON i.campaign_run_id = c.campaign_run_id
WHERE campaign_language IS DISTINCT FROM 'en'