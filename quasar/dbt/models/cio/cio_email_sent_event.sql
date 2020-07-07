SELECT
    coalesce(
        event #>>'{data, email_id}',
        event #>>'{data, variables, email_id}'
    ) AS email_id,
    event #>>'{data, customer_id}' as customer_id,
    event #>>'{data, email_address}' as email_address,
    CAST(
        event #>>'{data, template_id}' AS INTEGER
    ) AS template_id,
    event #>>'{data, subject}' as "subject",
    event ->> 'event_id' AS event_id,
    TO_TIMESTAMP(
        CAST(event ->> 'timestamp' AS INTEGER)
    ) AS "timestamp",
    event #>>'{data, variables, campaign, id}' as cio_campaign_id,
    event #>>'{data, variables, campaign, name}' as cio_campaign_name,
    event #>>'{data, variables, campaign, type}' as cio_campaign_type
FROM
    {{ source('cio', 'event_log') }} cel
WHERE
    event ->> 'event_type' = 'email_sent'
UNION
SELECT
    email_id,
    customer_id,
    email_address,
    template_id,
    "subject",
    event_id,
    "timestamp",
    NULL AS cio_campaign_id,
    NULL AS cio_campaign_name,
    NULL AS cio_campaign_type
FROM
    {{ source('cio_historical', 'cio_email_sent') }} ceso
WHERE
    -- Date we re-started saving raw C.io events to the event_log table
    "timestamp" < '2020-04-01'
