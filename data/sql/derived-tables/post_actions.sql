DROP MATERIALIZED VIEW IF EXISTS public.post_actions CASCADE;
CREATE MATERIALIZED VIEW public.post_actions AS (
	SELECT 
		*
	FROM :ft_rogue_actions
)
;
CREATE UNIQUE INDEX ON public.post_actions (created_at, id);
GRANT SELECT ON public.post_actions TO looker;
GRANT SELECT ON public.post_actions TO dsanalyst;
