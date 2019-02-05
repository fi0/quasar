DROP MATERIALIZED VIEW IF EXISTS ft_gambit_conversations_api.conversations_flattened_ft CASCADE;
CREATE MATERIALIZED VIEW ft_gambit_conversations_api.conversations_flattened_ft AS
(SELECT
   campaign_id AS campaign_id,
   created_at as created_at,
   _id AS conversation_id,
   import_source AS import_source,
   last_outbound_message AS last_outbound_message,
   paused AS paused,
   platform AS platform,
   platform_user_id AS platform_user_id,
   topic AS topic,
   updated_at AS updated_at,
   user_id AS user_id
FROM ft_gambit_conversations_api.conversations);

CREATE INDEX conversationidi on ft_gambit_conversations_api.conversations_flattened_ft(conversation_id);
CREATE INDEX platformuidi on ft_gambit_conversations_api.conversations_flattened_ft(platform_user_id);
CREATE INDEX useridi on ft_gambit_conversations_api.conversations_flattened_ft(user_id);
CREATE INDEX topic on ft_gambit_conversations_api.conversations_flattened_ft(topic);

GRANT SELECT on ft_gambit_conversations_api.conversations_flattened_ft TO looker;
GRANT SELECT on ft_gambit_conversations_api.conversations_flattened_ft to dsanalyst;
