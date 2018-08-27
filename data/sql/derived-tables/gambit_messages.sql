DROP MATERIALIZED VIEW IF EXISTS gambit_conversations.messages_flattened CASCADE;
CREATE MATERIALIZED VIEW gambit_conversations.messages_flattened AS
(SELECT
    (records->'agentId')::VARCHAR as agent_id,
    ((records->'attachments')::JSONB->0->>'url')::VARCHAR as attachment_url,
    ((records->'attachments')::JSONB->0->>'contentType')::VARCHAR as attachment_content_type,
    (records->'broadcastId')::VARCHAR as broadcast_id,
    (records->'campaignId')::VARCHAR as campaign_id,
    (records->'conversationId'->>'$oid')::VARCHAR as conversation_id,
    to_timestamp((((records->'createdAt'->>'$date')::BIGINT) / 1000)::DOUBLE PRECISION) as created_at,
    (records->'direction')::VARCHAR as direction,
    (records->'_id')::VARCHAR as message_id,
    (records->'macro')::VARCHAR as macro,
    (records->'match')::VARCHAR as match,
    to_timestamp((((records->'metadata'->'delivery'->'deliveredAt'->>'$date')::BIGINT) / 1000)::DOUBLE PRECISION) as delivered_at,
    (records->'metadata'->'delivery'->>'totalSegments')::INT as total_segments,
    (records->'platformMessageId')::VARCHAR as platform_message_id,
    (records->'template')::VARCHAR as template,
    records->'text' as text, (records->'topic')::VARCHAR as topic,
    (records->'userId')::VARCHAR as user_id
FROM gambit_conversations.messages_json);

CREATE INDEX platformmsgi on gambit_conversations.messages_flattened(platform_message_id);
CREATE INDEX usermidi on gambit_conversations.messages_flattened(user_id);

GRANT SELECT on gambit_conversations.messages_flattened TO looker;
GRANT SELECT on gambit_conversations.messages_flattened to dsanalyst;
