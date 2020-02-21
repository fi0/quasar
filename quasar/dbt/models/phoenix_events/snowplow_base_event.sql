SELECT
    event_id AS event_id,
    app_id AS event_source,
    collector_tstamp AS event_datetime,
    se_property AS event_name,
    "event" AS event_type,
    page_urlhost AS host,
    page_urlpath AS "path",
    page_urlquery AS query_parameters,
    se_category,
    -- https://www.pivotaltracker.com/story/show/171161608
    CASE
      WHEN
        (se_property = 'phoenix_clicked_voter_registration_action' AND se_action = 'undefined_clicked')
      THEN
        'button_clicked'
      ELSE
        se_action END AS se_action,
    se_label,
    domain_sessionid AS session_id,
    domain_sessionidx AS session_counter,
    dvce_type AS browser_size,
    user_id AS northstar_id,
    domain_userid AS device_id,
    refr_urlhost AS referrer_host,
    refr_urlpath AS referrer_path,
    refr_source AS referrer_source
  FROM {{ env_var('FT_SNOWPLOW') }}."event"
  WHERE event_id NOT IN
  (SELECT event_id
   FROM {{ env_var('FT_SNOWPLOW') }}.ua_parser_context u
   WHERE u.useragent_family SIMILAR TO
   '%(bot|crawl|slurp|spider|archiv|spinn|sniff|seo|audit|survey|pingdom|worm|capture|(browser|screen)shots|analyz|index|thumb|check|facebook|YandexBot|Twitterbot|a_archiver|facebookexternalhit|Bingbot|Googlebot|Baiduspider|360(Spider|User-agent)|Ghost)%')
