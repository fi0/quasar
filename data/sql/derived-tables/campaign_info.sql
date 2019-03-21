DROP MATERIALIZED VIEW IF EXISTS :campaign_info_all CASCADE;
CREATE MATERIALIZED VIEW IF NOT EXISTS :campaign_info_all AS ( 
    SELECT c.field_campaigns_target_id as campaign_node_id,
           n2.title as campaign_node_id_title,
           c.entity_id as campaign_run_id,
           n1.title as campaign_run_id_title,
           fdfct.field_campaign_type_value as campaign_type,
           c.language as campaign_language,
           fdfrd.field_run_date_value as campaign_run_start_date,
           fdfrd.field_run_date_value2 as campaign_run_end_date,
           to_timestamp(n1.created) as campaign_created_date,
           fdfrn.field_reportback_noun_value as campaign_noun,
           fdfrv.field_reportback_verb_value as campaign_verb,
           array_to_string(array_agg(distinct ttd2.name), ', ') as campaign_cause_type,
           array_to_string(array_agg(distinct fdfcta.field_call_to_action_value), ', ') as campaign_cta,
           array_to_string(array_agg(distinct ttd1.name), ', ') as campaign_action_type 
    FROM :field_data_field_campaigns c 
    LEFT JOIN :node n1 
        ON n1.nid = c.entity_id 
    LEFT JOIN :node n2 
        ON n2.nid = c.field_campaigns_target_id 
    LEFT JOIN :field_data_field_campaign_type fdfct 
        ON c.field_campaigns_target_id = fdfct.entity_id 
    LEFT JOIN :field_data_field_run_date fdfrd 
        ON c.entity_id = fdfrd.entity_id and c.language = fdfrd.language 
    LEFT JOIN :field_data_field_call_to_action fdfcta 
        ON c.field_campaigns_target_id = fdfcta.entity_id and c.language = fdfcta.language 
    LEFT JOIN :field_data_field_reportback_noun fdfrn 
        ON c.field_campaigns_target_id = fdfrn.entity_id and c.language = fdfrn.language 
    LEFT JOIN :field_data_field_reportback_verb fdfrv 
        ON c.field_campaigns_target_id = fdfrv.entity_id and c.language = fdfrv.language 
    LEFT JOIN :field_data_field_action_type fdfat 
        ON fdfat.entity_id = c.field_campaigns_target_id 
    LEFT JOIN :taxonomy_term_data ttd1 
        ON fdfat.field_action_type_tid = ttd1.tid 
    LEFT JOIN :field_data_field_cause fdfc 
        ON fdfc.entity_id = c.field_campaigns_target_id 
    LEFT JOIN :taxonomy_term_data ttd2 
        ON fdfc.field_cause_tid = ttd2.tid 
    WHERE c.bundle = 'campaign_run' 
    GROUP BY 1,2,3,4,5,6,7,8,9,10,11 
    ORDER BY c.field_campaigns_target_id, fdfrd.field_run_date_value);
    
DROP MATERIALIZED VIEW IF EXISTS public.campaign_info CASCADE;
CREATE MATERIALIZED VIEW IF NOT EXISTS public.campaign_info AS (
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
	FROM ft_dosomething_rogue.campaigns c
	LEFT JOIN :campaign_info_all i ON i.campaign_run_id = c.campaign_run_id
	WHERE i.campaign_language = 'en' OR i.campaign_language IS NULL 
);
CREATE UNIQUE INDEX ON public.campaign_info (campaign_run_id, campaign_id);
GRANT SELECT ON public.campaign_info TO dsanalyst;
GRANT SELECT ON public.campaign_info TO looker;


DROP MATERIALIZED VIEW IF EXISTS public.campaign_info_international CASCADE;
CREATE MATERIALIZED VIEW IF NOT EXISTS public.campaign_info_international AS (
	SELECT 
		c.id AS campaign_id,
		c.internal_title AS campaign_name,
		i.*
	FROM :campaign_info_all i
	LEFT JOIN ft_dosomething_rogue.campaigns c ON i.campaign_run_id = c.campaign_run_id
	WHERE campaign_language IS DISTINCT FROM 'en'
);
GRANT SELECT ON public.campaign_info_international TO dsanalyst;
GRANT SELECT ON public.campaign_info_international TO looker;
