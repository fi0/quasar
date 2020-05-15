SELECT
	coalesce(
	    event #>>'{data, email_id}',
	    event #>>'{data, variables, email_id}'
	) AS email_id,
	event #>>'{data, customer_id}' as customer_id,
	event #>>'{data, email_address}' as email_address,
	event #>>'{data, template_id}' as template_id,
	event #>>'{data, subject}' as subject,
	event #>>'{data, href}' as href,
	event #>>'{data, link_id}' as link_id,
	event ->> 'event_id' AS event_id,
	TO_TIMESTAMP(CAST(event ->> 'timestamp' AS INTEGER)) AS "timestamp",
	event #>>'{data, variables, campaign, id}' as cio_campaign_id,
	event #>>'{data, variables, campaign, name}' as cio_campaign_name,
	event #>>'{data, variables, campaign, type}' as cio_campaign_type,
	event #>>'{data, event_type}' as event_type
FROM
    {{ source('cio', 'event_log') }} cel
WHERE event->event_type IN ('email_bounced', 'email_converted', 'email_opened', 'email_unsubscribed')
