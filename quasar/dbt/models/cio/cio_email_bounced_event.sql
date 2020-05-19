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
    event #>>'{data, subject}' as subject,
    event ->> 'event_id' AS event_id,
    TO_TIMESTAMP(CAST(event ->> 'timestamp' AS INTEGER)) AS "timestamp",
    event #>>'{data, variables, campaign, id}' as cio_campaign_id,
    event #>>'{data, variables, campaign, name}' as cio_campaign_name
FROM
    {{ source('cio', 'event_log') }} cel
WHERE event #>>'{data, event_type}' = 'email_bounced'
UNION ALL
SELECT
    email_id,
    customer_id,
    email_address,
    template_id,
    "subject",
    event_id,
    "timestamp",
    NULL AS cio_campaign_id,
    NULL AS cio_campaign_name
FROM {{ source('cio', 'email_bounced_old') }}
