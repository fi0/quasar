DROP MATERIALIZED VIEW IF EXISTS gambit_conversations.conversations_raw;
CREATE MATERIALIZED VIEW gambit_conversations.conversations_raw AS
(SELECT
   (records->>'campaignId')::varchar as campaign_id, to_timestamp((((records->'createdAt'->>'$date')::BIGINT) / 1000)::double precision) as created_at,
   (records->'_id'->>'$oid')::varchar as conversation_id, (records->>'importSource')::varchar as import_source,
   (records->'lastOutboundMessage'->>'$oid')::varchar as last_outbound_message, (records->>'paused')::varchar as paused,
   (records->>'platform')::varchar as platform, (records->>'platformUserId')::varchar as platform_user_id,
   (records->>'topic')::varchar as topic, to_timestamp((((records->'updatedAt'->>'$date')::BIGINT) / 1000)::double precision) as updated_at,
   (records->>'userId')::varchar as user_id from gambit_conversations.conversations_json);

CREATE INDEX conversationidi on gambit_conversations.conversations_raw(conversation_id);
CREATE INDEX platformuidi on gambit_conversations.conversations_raw(platform_user_id);
CREATE INDEX useridi on gambit_conversations.conversations_raw(user_id);
CREATE INDEX topic on gambit_conversations.conversations_raw(topic);

GRANT SELECT on gambit_conversations.conversations_raw TO looker;
GRANT SELECT on gambit_conversations.conversations_raw to dsanalyst;
