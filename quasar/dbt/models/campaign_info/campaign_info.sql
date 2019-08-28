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
	i.campaign_cause_type,
	i.campaign_noun,
	i.campaign_verb,
	i.campaign_cta
FROM :campaigns c
LEFT JOIN :campaign_info_all i ON i.campaign_run_id = c.campaign_run_id
WHERE i.campaign_language = 'en' OR i.campaign_language IS NULL 
);
CREATE UNIQUE INDEX ON :campaign_info (campaign_run_id, campaign_id);
GRANT SELECT ON :campaign_info TO dsanalyst;
GRANT SELECT ON :campaign_info TO looker;


DROP MATERIALIZED VIEW IF EXISTS :campaign_info_international CASCADE;
CREATE MATERIALIZED VIEW IF NOT EXISTS :campaign_info_international AS (
SELECT 
	c.id AS campaign_id,
	c.internal_title AS campaign_name,
	i.*
FROM :campaign_info_all i
LEFT JOIN :campaigns c ON i.campaign_run_id = c.campaign_run_id
WHERE campaign_language IS DISTINCT FROM 'en'
