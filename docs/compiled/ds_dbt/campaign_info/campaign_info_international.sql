SELECT 
	c.campaign_id,
	c.campaign_name,
	i.*
FROM "quasar_prod_warehouse"."ds_dbt"."campaign_info_all" i
LEFT JOIN ft_dosomething_rogue.campaigns c ON i.campaign_run_id = c.campaign_run_id
WHERE campaign_language IS DISTINCT FROM 'en'