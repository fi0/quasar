DROP MATERIALIZED VIEW IF EXISTS gambit_conversations.conversations_flattened CASCADE;
CREATE MATERIALIZED VIEW gambit_conversations.conversations_flattened AS
(SELECT
   records ->> 'campaignId' AS campaign_id,
   to_timestamp((((records #>> '{createdAt,$date}')::BIGINT) / 1000)::DOUBLE PRECISION) AS created_at,
   records #>> '{_id,$oid}' AS conversation_id,
   records ->> 'importSource' AS import_source,
   records #>> '{lastOutboundMessage,$oid}' AS last_outbound_message,
   records ->> 'paused' AS paused,
   records ->> 'platform' AS platform,
   records ->> 'platformUserId' AS platform_user_id,
   records ->> 'topic' AS topic,
   to_timestamp((((records #>> '{updatedAt,$date}')::BIGINT) / 1000)::DOUBLE PRECISION) AS updated_at,
   records ->> 'userId' AS user_id 
FROM gambit_conversations.conversations_json);

CREATE INDEX conversationidi on gambit_conversations.conversations_flattened(conversation_id);
CREATE INDEX platformuidi on gambit_conversations.conversations_flattened(platform_user_id);
CREATE INDEX useridi on gambit_conversations.conversations_flattened(user_id);
CREATE INDEX topic on gambit_conversations.conversations_flattened(topic);

GRANT SELECT on gambit_conversations.conversations_flattened TO looker;
GRANT SELECT on gambit_conversations.conversations_flattened to dsanalyst;