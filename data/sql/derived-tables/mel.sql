DROP MATERIALIZED VIEW IF EXISTS public.member_event_log CASCADE; 
CREATE MATERIALIZED VIEW public.member_event_log AS 
(SELECT
    MD5(concat(a.northstar_id, a."timestamp", a.action_id, a.action_serial_id)) AS event_id,
    a.northstar_id AS northstar_id,
    a."timestamp" AS "timestamp",
    a."action" AS action_type,
    a.action_id AS action_id,
    a."source" AS "source",
    a.action_serial_id AS action_serial_id,
    a.channel AS channel
FROM ( 
    SELECT -- CAMPAIGN SIGNUP WITH CHANNEL
        DISTINCT s.northstar_id AS northstar_id,
        s.created_at AS "timestamp",
        'signup' AS "action",
        '1' AS action_id, 
        s."source" AS "source",
        s.id::varchar AS action_serial_id,
        s.channel AS channel
    FROM      
         (SELECT 
            sd.northstar_id,
            sd.created_at,
            sd.id,
            sd."source",
            sd.deleted_at, 
            (CASE WHEN sd."source" ILIKE '%%sms%%' THEN 'sms'
            WHEN sd."source" NOT LIKE '%%sms%%'AND sd."source" NOT LIKE '%%email%%' AND sd."source" NOT LIKE '%%niche%%' OR sd."source" IS NULL THEN 'web'
            WHEN sd."source" ILIKE '%%email%%' THEN 'email'
            WHEN sd."source" ILIKE '%%niche%%' THEN 'niche_coregistration'
            WHEN sd."source" NOT LIKE '%%sms%%'AND sd."source" NOT LIKE '%%email%%' AND sd."source" NOT LIKE '%%niche%%' AND sd."source" IS NOT NULL THEN 'other' END) AS "channel"
        FROM 
            (SELECT 
                stemp.id,
                max(stemp.updated_at) AS updated_at
            FROM rogue.signups stemp
            GROUP BY stemp.id) s_maxupt
        INNER JOIN rogue.signups sd
            ON sd.id = s_maxupt.id AND sd.updated_at = s_maxupt.updated_at
        ) s 
    WHERE s.deleted_at IS NULL
    AND s.id NOT IN (SELECT c.signup_id AS id 
    				FROM campaign_activity c 
    				WHERE c.signup_source = 'importer-client' 
    				AND c.signup_created_at > c.post_created_at)
    UNION ALL
    SELECT -- CAMPAIGN POSTS WITH CHANNEL
        DISTINCT p.northstar_id AS northstar_id,
        p.created_at AS "timestamp",
        'post' AS "action",
        '2' AS action_id,
        p."source" AS "source",
        p.id::varchar AS action_serial_id,
        p.channel AS channel
    FROM 
        (
        SELECT 
            pd.northstar_id,
            pd.created_at,
            pd.id,
            pd."source",
            pd.deleted_at,
            pd."type",
            (CASE WHEN pd."source" ILIKE '%%sms%%' THEN 'sms'
            WHEN pd."source" ILIKE '%%phoenix%%' OR pd."source" IS NULL THEN 'web'
            WHEN pd."source" ILIKE '%%app%%' THEN 'mobile_app'
            WHEN pd."source" NOT LIKE '%%phoenix%%' AND pd."source" NOT LIKE '%%sms%%' AND pd."source" IS NOT NULL AND pd."source" NOT LIKE '%%app%%' THEN 'other' END) AS "channel"
        FROM 
            (SELECT 
                ptemp.id,
                max(ptemp.updated_at) AS updated_at
            FROM rogue.posts ptemp
            GROUP BY ptemp.id) p_maxupt
        INNER JOIN rogue.posts pd
        ON pd.id = p_maxupt.id AND pd.updated_at = p_maxupt.updated_at
            ) p
    WHERE p.deleted_at IS NULL
    UNION ALL -- SITE ACCESS
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
    UNION ALL -- SITE LOGIN
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
    UNION ALL 
    SELECT -- ACCOUNT CREATION 
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
        GROUP BY u_create.id) u
    UNION ALL 
    SELECT -- LAST MESSAGED SMS 
        DISTINCT g.user_id AS northstar_id,
        g.created_at AS "timestamp",
        'messaged_gambit' AS "action", 
        '6' AS action_id,
        'SMS' AS "source",
        g.message_id AS action_serial_id,
        'sms' AS "channel"
    FROM
        public.gambit_messages_inbound g
    WHERE 
    	g.user_id IS NOT NULL
    	AND g.macro <> 'subscriptionStatusStop' 
    UNION ALL 
        SELECT -- CLICKED EMAIL LINK 
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
    UNION ALL 
    SELECT DISTINCT -- SMS LINK CLICKS FROM BERTLY 
        b.northstar_id AS northstar_id,
        b.click_time AS "timestamp",
        'bertly_link_click' AS "action",
        '10' AS action_id,
        'bertly' AS "source",
        b.click_id AS action_serial_id,
        b."source" AS "channel"
    FROM public.bertly_clicks b 
    WHERE b.northstar_id IS NOT NULL
      ) AS a 
    ); 
CREATE UNIQUE INDEX ON public.member_event_log (event_id, northstar_id, action_id, action_serial_id, channel, "timestamp", "source");
GRANT SELECT ON public.member_event_log TO looker;
GRANT SELECT ON public.member_event_log TO dsanalyst;
