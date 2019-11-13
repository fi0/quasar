WITH sessions AS (
SELECT
    session_id,
    min(device_id) AS device_id,
    min(event_datetime) AS landing_datetime,
    max(event_datetime) AS ending_datetime,
    date_part(
	'seconds', max(event_datetime) - min(event_datetime)
    ) AS session_duration_seconds,
    count(DISTINCT CASE WHEN event_name = 'view' THEN "path" END) AS num_pages_viewed
FROM "quasar_prod_warehouse"."ds_dbt"."snowplow_phoenix_events"
GROUP BY session_id
),
entry_exit_pages AS (
SELECT DISTINCT
    session_id,
    first_value("path") OVER (PARTITION BY session_id ORDER BY event_datetime 
	ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS landing_page,
    first_value(event_id) OVER (PARTITION BY session_id ORDER BY event_datetime 
	ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS event_id,
    last_value("path") OVER (PARTITION BY session_id ORDER BY event_datetime 
	ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS exit_page
FROM "quasar_prod_warehouse"."ds_dbt"."snowplow_phoenix_events"
),
time_between_sessions AS (
SELECT DISTINCT
    device_id,
    session_id,
    LAG(ending_datetime) OVER (PARTITION BY device_id ORDER BY landing_datetime
	ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS prev_session_endtime
FROM sessions
)
SELECT
s.session_id,
p.event_id,
s.device_id,
s.landing_datetime,
s.ending_datetime,
s.session_duration_seconds,
s.num_pages_viewed,
p.landing_page,
p.exit_page,
date_part('day', s.landing_datetime - t.prev_session_endtime) AS days_since_last_session
FROM sessions s
LEFT JOIN entry_exit_pages p
ON p.session_id = s.session_id
LEFT JOIN time_between_sessions t
ON t.session_id = s.session_id