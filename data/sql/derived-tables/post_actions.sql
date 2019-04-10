DROP MATERIALIZED VIEW IF EXISTS public.post_actions CASCADE;
CREATE MATERIALIZED VIEW public.post_actions AS (
	SELECT 
		*
	FROM ft_dosomething_rogue.actions
)