SELECT
    MD5(concat(a.northstar_id, a."timestamp", a.action_id, a.action_serial_id)) AS event_id,
    a.northstar_id AS northstar_id,
    a."timestamp" AS "timestamp",
    a."action" AS action_type,
    a.action_id AS action_id,
    a."source" AS "source",
    a.action_serial_id AS action_serial_id,
    a.channel AS channel,
    CASE 
    	WHEN date_trunc('month', a."timestamp") = date_trunc('month', u.created_at) 
    	THEN 'New' 
    	ELSE 'Returning' END 
    	AS "type",
    MIN("timestamp") 
    	OVER 
    	(PARTITION BY a.northstar_id, date_trunc('month', a."timestamp")) 
    	AS first_action_month
FROM ( 
SELECT
    DISTINCT s.northstar_id AS northstar_id,
    s.created_at AS "timestamp",
    'signup' AS "action",
    '1' AS action_id, 
    s."source" AS "source",
    s.id::varchar AS action_serial_id,
(CASE WHEN s."source" ILIKE '%%sms%%' THEN 'sms'
WHEN s."source" NOT LIKE '%%sms%%'AND s."source" NOT LIKE '%%email%%' AND s."source" NOT LIKE '%%niche%%' OR s."source" IN ('rock-the-vote', 'turbovote') THEN 'web'
WHEN s."source" ILIKE '%%email%%' THEN 'email'
WHEN s."source" ILIKE '%%niche%%' THEN 'niche_coregistration'
WHEN s."source" NOT LIKE '%%sms%%'AND s."source" NOT LIKE '%%email%%' AND s."source" NOT LIKE '%%niche%%' AND s."source" NOT IN ('rock-the-vote', 'turbovote') AND s."source" IS NOT NULL THEN 'other' END) AS "channel"
FROM {{ ref('signups') }} s
WHERE s."source" IS DISTINCT FROM 'importer-client'
AND s."source" IS DISTINCT FROM 'rock-the-vote'
AND s."source" IS DISTINCT FROM 'turbovote'
UNION ALL
SELECT
    DISTINCT p.northstar_id AS northstar_id,
    p.created_at AS "timestamp",
    'post' AS "action",
    '2' AS action_id,
    p."source" AS "source",
    p.id::varchar AS action_serial_id,
(CASE WHEN p."source" ILIKE '%%sms%%' THEN 'sms'
WHEN p."source" ILIKE '%%phoenix%%' OR p."source" IS NULL or p."source" ILIKE '%%turbovote%%' THEN 'web'
WHEN p."source" ILIKE '%%app%%' THEN 'mobile_app'
WHEN p."source" NOT LIKE '%%phoenix%%' AND p."source" NOT LIKE '%%sms%%' AND p."source" IS NOT NULL AND p."source" NOT LIKE '%%app%%' and p."source" NOT LIKE '%%turbovote%%' THEN 'other' END) AS "channel"
FROM {{ ref('posts') }} p
WHERE p.status IN ('accepted', 'confirmed', 'register-OVR', 'register-form', 'pending')
UNION ALL
SELECT DISTINCT 
    u_access.id AS northstar_id,
    u_access.last_accessed_at AS "timestamp",
    'site_access' AS "action",
    '3' AS action_id,
    NULL AS "source",
    '0' AS action_serial_id,
    'web' AS channel
FROM northstar.users u_access
WHERE u_access.last_accessed_at IS NOT NULL
AND u_access."source" IS DISTINCT FROM 'runscope'
AND u_access."source" IS DISTINCT FROM 'runscope-client'
AND u_access.email IS DISTINCT FROM 'runscope-scheduled-test@dosomething.org'
AND u_access.email IS DISTINCT FROM 'juy+runscopescheduledtests@dosomething.org'
AND (u_access.email NOT ILIKE '%%@example.org%%' OR u_access.email IS NULL) 
UNION ALL
SELECT DISTINCT 
    u_login.id AS northstar_id,
    u_login.last_authenticated_at AS "timestamp",
    'site_login' AS "action",
    '4' AS action_id,
    NULL AS "source",
    '0' AS action_serial_id,
    'web' AS channel
FROM northstar.users u_login
WHERE u_login.last_authenticated_at IS NOT NULL 
AND u_login."source" IS DISTINCT FROM 'runscope'
AND u_login."source" IS DISTINCT FROM 'runscope-client'
AND u_login.email IS DISTINCT FROM 'runscope-scheduled-test@dosomething.org'
AND u_login.email IS DISTINCT FROM 'juy+runscopescheduledtests@dosomething.org'
AND (u_login.email NOT ILIKE '%%@example.org%%' OR u_login.email IS NULL) 
UNION ALL 
SELECT
    DISTINCT u.id AS northstar_id,
    u.created_at AS "timestamp",
    'account_creation' AS action, 
    '5' AS action_id,
    u."source" AS "source",
    '0' AS action_serial_id, 
    (CASE WHEN u."source" ILIKE '%%sms%%' THEN 'sms'
    WHEN u."source" ILIKE '%%phoenix%%' OR u."source" IS NULL THEN 'web'
    WHEN u."source" ILIKE '%%niche%%' THEN 'niche_coregistration'
    WHEN u."source" NOT LIKE '%%niche%%' AND u."source" NOT LIKE '%%sms%%' AND u."source" NOT LIKE '%%phoenix%%' AND u."source" IS NOT NULL THEN 'other' END) AS "channel"
FROM
    (SELECT 
            u_create.id,
            max(u_create."source") AS "source",
            min(u_create.created_at) AS created_at
    FROM northstar.users u_create
WHERE u_create."source" IS DISTINCT FROM 'importer-client'
AND u_create."source" IS DISTINCT FROM 'runscope'
AND u_create."source" IS DISTINCT FROM 'runscope-client'
AND u_create.email IS DISTINCT FROM 'runscope-scheduled-test@dosomething.org'
AND u_create.email IS DISTINCT FROM 'juy+runscopescheduledtests@dosomething.org'
AND (u_create.email NOT ILIKE '%%@example.org%%' OR u_create.email IS NULL) 
    GROUP BY u_create.id) u
UNION ALL 
SELECT
    DISTINCT g.user_id AS northstar_id,
    g.created_at AS "timestamp",
    'messaged_gambit' AS "action", 
    '6' AS action_id,
    'SMS' AS "source",
    g.message_id AS action_serial_id,
    'sms' AS "channel"
FROM
    {{ ref('gambit_messages_inbound') }} g
WHERE 
	g.user_id IS NOT NULL
	AND g.macro <> 'subscriptionStatusStop' 
UNION ALL 
    SELECT
        DISTINCT cio.customer_id AS northstar_id,
        cio."timestamp" AS "timestamp",
        'clicked_link' AS "action",
        '7' AS action_id,
        cio.template_id::CHARACTER AS "source",
        cio.event_id AS action_serial_id, 
        'email' AS "channel"
    FROM
        cio.email_event cio
    WHERE 
        cio.event_type = 'email_clicked'
    AND cio.customer_id IS NOT NULL
UNION ALL 
SELECT DISTINCT
    b.northstar_id AS northstar_id,
    b.click_time AS "timestamp",
    CONCAT('bertly_link_', b.interaction_type) AS "action",
    '10' AS action_id,
    'bertly' AS "source",
    b.click_id AS action_serial_id,
    b."source" AS "channel"
FROM {{ ref('bertly_clicks') }} b
INNER JOIN public.users u
ON b.northstar_id = u.northstar_id
WHERE b.northstar_id IS NOT NULL
AND b.interaction_type IS DISTINCT FROM 'preview'
) AS a
LEFT JOIN public.users u ON u.northstar_id = a.northstar_id
