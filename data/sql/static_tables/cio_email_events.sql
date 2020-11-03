-- This table re-joins these 3 historical cio tables:
-- 1. cio_email_bounced
-- 2. cio_email_event
-- 3. cio_email_sent
-- back into a single table of events. This is necessary since we do not have a raw event payload for each of these
-- before April 1st 2020.
SELECT
    customer_id,
    email_address,
    email_id,
    event_id,
    -- the data in the old table was filtered on this event_type value so all events here are of these type
    -- we need to populate the value here for consistent union with the other old tables
    'email_bounced' AS event_type,
    NULL AS href,
    NULL AS link_id,
    subject,
    template_id,
    "timestamp"
FROM
    historical_analytics.cio_email_bounced ceb
UNION
SELECT
    -- found some empty string customer_id values. Let's make it consistently null in that case.
    CASE
        WHEN customer_id = '' THEN NULL
        ELSE customer_id
    END AS customer_id,
    email_address,
    email_id,
    event_id,
    event_type,
    href,
    link_id,
    subject,
    template_id,
    "timestamp"
FROM
    historical_analytics.cio_email_event cee
UNION
SELECT
    customer_id,
    email_address,
    email_id,
    event_id,
    -- the data in the old table was filtered on this event_type value so all events here are of these type
    -- we need to populate the value here for consistent union with the other old tables
    'email_sent' AS event_type,
    NULL AS href,
    NULL AS link_id,
    subject,
    template_id,
    "timestamp"
FROM
    historical_analytics.cio_email_sent ces
