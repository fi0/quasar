SELECT 
	c.id AS campaign_id,
	c.campaign_run_id,
	c.internal_title AS campaign_name,
	c.cause AS campaign_cause,
	c.start_date AS campaign_run_start_date,
	c.end_date AS campaign_run_end_date,
	c.created_at AS campaign_created_date,
	COALESCE(i.campaign_node_id, c.id) AS campaign_node_id,
	i.campaign_node_id_title,
	i.campaign_run_id_title,
	i.campaign_action_type,
	COALESCE(c.cause, i.campaign_cause_type) AS campaign_cause_type,
	i.campaign_noun,
	i.campaign_verb,
	i.campaign_cta
FROM ft_dosomething_rogue.campaigns c
LEFT JOIN public.campaign_info_ashes_snapshot  i ON i.campaign_run_id = c.campaign_run_id
WHERE i.campaign_language = 'en' OR i.campaign_language IS NULL