DROP MATERIALIZED VIEW IF EXISTS gambit.conversations_json CASCADE;
CREATE MATERIALIZED VIEW gambit.conversations_json AS
(SELECT 
	conversations._doc::jsonb AS records 
FROM gambit.conversations);

DROP MATERIALIZED VIEW IF EXISTS gambit.messages_json CASCADE;
CREATE MATERIALIZED VIEW gambit.messages_json AS
(SELECT
	regexp_replace(messages._doc, '\\u0000', '', 'g')::jsonb AS records 
FROM gambit.messages);