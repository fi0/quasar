SELECT
  device_id,
  campaign_id,
  min_view_session_id,
  min_view_datetime,
  session_referrer_host,
  session_utm_source,
  session_utm_campaign,
  min_intent_datetime
FROM
  (
    SELECT
      dcj.device_id,
      dcj.campaign_id,
      dcj.min_view_session_id,
      dcj.min_view_datetime,
      CASE
        WHEN s.session_referrer_host = '' THEN NULL
        ELSE s.session_referrer_host
      END AS session_referrer_host,
      s.session_utm_source,
      s.session_utm_campaign,
      dcj.min_intent_datetime
    FROM
      (
        --was the device_campaign_session table
        SELECT
          device_id,
          campaign_id,
          min_view_datetime,
          min_intent_datetime,
          min_view_session_id
        FROM
          (
            SELECT
              device_id,
              campaign_id,
              min(event_datetime) over (PARTITION by device_id || '-' || campaign_id) AS min_view_datetime,
              min(
                -- set consist only of event_datetime of "phoenix_clicked_signup" events
                CASE
                  WHEN event_name = 'phoenix_clicked_signup' THEN event_datetime
                END
              ) over (
                PARTITION by device_id || '-' || campaign_id
              ) AS min_intent_datetime,
              first_value(session_id) over (
                PARTITION by device_id || '-' || campaign_id
                ORDER BY
                  event_datetime RANGE BETWEEN UNBOUNDED PRECEDING
                  AND UNBOUNDED FOLLOWING
              ) AS min_view_session_id,
              event_name,
              event_datetime
            FROM
              {{ ref('phoenix_events_combined') }}
            WHERE
              campaign_id IS NOT NULL
          ) dca --device_campaign_all
        GROUP BY
          1,
          2,
          3,
          4,
          5
      ) dcj --device_campaign_journey
      JOIN {{ ref('phoenix_sessions_combined') }} s ON (dcj.min_view_session_id = s.session_id)
  ) fj --full_journey
