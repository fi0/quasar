DROP MATERIALIZED VIEW IF EXISTS gambit_conversations.messages_flattened CASCADE;
CREATE MATERIALIZED VIEW gambit_conversations.messages_flattened AS
(SELECT
    records ->> 'agentId' AS agent_id,
    records #>> '{attachments,url}' AS attachment_url,
    records ->> '{attachments,contentType}'as attachment_content_type,
    records ->> 'broadcastId' AS broadcast_id,
    records ->> 'campaignId' AS campaign_id,
    records #>> '{conversationId,$oid}' AS conversation_id,
    to_timestamp((((records #>> '{createdAt,$date}')::BIGINT) / 1000)::DOUBLE PRECISION) AS created_at,
    records ->> 'direction' AS direction,
    records #>> '{_id,$oid}' AS message_id,
    records ->> 'macro' AS macro,
    records ->> 'match' AS match,
    to_timestamp((records #> '{metadata,delivery}' #>> '{deliveredAt,$date}')::BIGINT / 1000::DOUBLE PRECISION) AS delivered_at,
    (records #> '{metadata,delivery}' ->> 'totalSegments')::INT AS total_segments,
    records ->> 'platformMessageId' AS platform_message_id,
    records ->> 'template' AS template,
    records ->> 'text' AS text, 
    records ->> 'topic' AS topic,
    records ->> 'userId' AS user_id
FROM gambit_conversations.messages_json);

CREATE INDEX platformmsgi ON gambit_conversations.messages_flattened(platform_message_id);
CREATE INDEX usermidi ON gambit_conversations.messages_flattened(user_id);

GRANT SELECT ON gambit_conversations.messages_flattened TO looker;
GRANT SELECT ON gambit_conversations.messages_flattened to dsanalyst;
