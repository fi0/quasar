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
	event #>>'{data, href}' as href,
	event #>>'{data, link_id}' as link_id,
	event ->> 'event_id' AS event_id,
	event #>>'{data, event_type}' as event_type,
	TO_TIMESTAMP(CAST(event ->> 'timestamp' AS INTEGER)) AS "timestamp",
	event #>>'{data, variables, campaign, id}' as cio_campaign_id,
	event #>>'{data, variables, campaign, name}' as cio_campaign_name,
	event #>>'{data, variables, campaign, type}' as cio_campaign_type
FROM
    {{ source('cio', 'event_log') }} cel
WHERE event #>>'{data, event_type}' IN ('email_bounced', 'email_converted', 'email_opened', 'email_unsubscribed')
UNION
SELECT
    email_id,
    customer_id,
    email_address,
    template_id,
    "subject",
    href,
    link_id,
    event_id,
    event_type,
    "timestamp",
    NULL AS cio_campaign_id,
    NULL AS cio_campaign_name,
    NULL AS cio_campaign_type
FROM {{ source('cio', 'email_event_old') }}
WHERE
    -- Date we re-started saving raw C.io events to the event_log table
    timestamp < '2020-04-01'
