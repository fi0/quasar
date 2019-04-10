DROP MATERIALIZED VIEW IF EXISTS :ft_rogue_actions CASCADE;
CREATE MATERIALIZED VIEW :ft_rogue_actions AS (
	SELECT 
		*
	FROM :ft_rogue_actions
)
;
CREATE UNIQUE INDEX ON :ft_rogue_actions (created_at, id);
GRANT SELECT ON :ft_rogue_actions TO looker;
GRANT SELECT ON :ft_rogue_actions TO dsanalyst;
