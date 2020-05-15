SELECT
    event #>>'{data, email_id}' as email_id,
    event #>>'{data, customer_id}' as customer_id,
    event #>>'{data, email_address}' as email_address,
    event ->> 'event_id' AS event_id,
    TO_TIMESTAMP(cast(event ->> 'timestamp' AS INTEGER)) AS "timestamp",
    event ->> 'event_type' AS event_type
FROM
    { { source('cio', 'event_log') } } cel
WHERE
    event ->> 'event_type' IN ('customer_subscribed', 'customer_unsubscribed')
