with
--Campaigns with Online/Offline Post Components
campaign_online as (
  select campaign_id, count(distinct online) as online_count, min(case when online=true then 'Online' else 'Offline' end) as min_online
  from {{ ref('post_actions') }}
  group by 1
)
,
campaign_online_combo as (
    select campaign_id, case when online_count>1 then 'Both' else min_online end as online_offline
    from campaign_online
)
,
--Campaigns and Action Types
campaign_action as (
  select campaign_id, action_type
  from {{ ref('post_actions') }}
  where action_type is not null and action_type<>''
  group by 1, 2
)
,
--Campaigns and Action Types Combined
campaign_action_combo as (
    select campaign_id, string_agg(action_type, ' , ' order by action_type) as action_types
    from campaign_action
    group by 1
)
,
-- Campaigns and Scholarship
campaign_scholarship as (
  select campaign_id, count(case when scholarship_entry=true then 1 end) as scholarship
  from {{ ref('post_actions') }}
  group by 1
)
,
-- Campaigns and Scholarship Combined
campaign_scholarship_combo as (
    select campaign_id, (case when scholarship>0 then 'Scholarship' else 'Not Scholarship' end) as scholarship
    from campaign_scholarship
)
,
--Campaigns and Action Types
campaign_post_type as (
  select campaign_id, post_type
  from {{ ref('post_actions') }}
  where post_type is not null and post_type<>''
  group by 1, 2
)
,
--Campaigns and Action Types Combined
campaign_post_type_combo as (
    select campaign_id, string_agg(post_type, ' , ' order by post_type) as post_types
    from campaign_post_type
    group by 1
)
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
	case when i.campaign_action_type = '' then null else i.campaign_action_type end as campaign_action_type,
	COALESCE(
		case when c.cause = '' then null else c.cause end, 
		case when i.campaign_cause_type = '' then null else i.campaign_cause_type end
	) AS campaign_cause_type,
	i.campaign_noun,
	i.campaign_verb,
	i.campaign_cta,
	case when a.action_types = '' then null else a.action_types end as action_types,
	o.online_offline,
	s.scholarship,
	p.post_types
FROM {{ env_var('FT_ROGUE') }}.campaigns c
LEFT JOIN {{ env_var('CAMPAIGN_INFO_ASHES_SNAPSHOT') }} i ON i.campaign_run_id = c.campaign_run_id
LEFT JOIN campaign_action_combo a on c.id = a.campaign_id
LEFT JOIN campaign_online_combo o on c.id = o.campaign_id
LEFT JOIN campaign_scholarship_combo s on c.id = s.campaign_id
LEFT JOIN campaign_post_type_combo p on c.id = p.campaign_id
WHERE i.campaign_language = 'en' OR i.campaign_language IS null
