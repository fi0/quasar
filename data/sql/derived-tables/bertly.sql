DROP MATERIALIZED VIEW IF EXISTS public.bertly_clicks CASCADE;
CREATE MATERIALIZED VIEW public.bertly_clicks AS (
	SELECT 
		*,
		(regexp_split_to_array(
			(regexp_split_to_array(
				(regexp_split_to_array(
					c.target_url, 'user')
				)[2], E'[=:]+')
			)[2], 
			E'[^a-zA-Z0-9]')
		)[1] AS northstar_id,
		COALESCE(
			(regexp_split_to_array(b.target_url, 'broadcastid=', 'i'))[2], 
			(regexp_split_to_array(b.target_url, 'broadcastid_'))[2],
			(regexp_split_to_array(b.target_url, 'broadcast_'))[2]
				) AS broadcast_id,
		(CASE WHEN target_url ilike '%%source=web%%' THEN 'web' 
			WHEN target_url ilike '%%source=email%%' THEN 'email'  
			ELSE 'sms' 
			END) AS SOURCE 
	FROM bertly.clicks c
);
GRANT SELECT ON public.campaign_activity TO looker;
GRANT SELECT ON public.campaign_activity TO dsanalyst;
