SELECT 
	c.id AS campaign_id,
	c.internal_title AS campaign_name,
	i.*
FROM "quasar_prod_warehouse"."dbt_sena_ft_dosomething_rogue"."campaign_info_all" i
LEFT JOIN "quasar_prod_warehouse"."dbt_sena"."campaign_info" c ON i.campaign_run_id = c.campaign_run_id
WHERE campaign_language IS DISTINCT FROM 'en'