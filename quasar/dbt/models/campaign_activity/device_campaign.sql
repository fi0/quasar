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
      -- Let's add marketing enriching data here. Necessary for dashboards in Looker.
      CASE
        WHEN s.session_referrer_host = '' THEN NULL
        ELSE s.session_referrer_host
      END AS session_referrer_host,
      s.session_utm_source,
      s.session_utm_campaign,
      dcj.min_intent_datetime
    FROM
      (
        -- select the new window aggregated properties and group them so we get rid of duplicates
        -- TODO: would a DISTINCT work for this instead?
        SELECT
          device_id,
          campaign_id,
          min_view_datetime,
          min_intent_datetime,
          min_view_session_id
        FROM
          (
            -- This query gets all the events that contain a campaign id (campaign_id is not null).
            -- It adds 3 fields:
            -- 1. min_view_datetime: The first time this device_id was active in this campaign_id
            -- 2. min_intent_datetime: The first time this device_id attempted to sign up to the campaign_id
            -- 3. min_view_session_id: The first session_id that matches the action in min_view_datetime.
            --    This is the session_id we attribute the first action (event) on this campaign_id
            --    by this device_id.
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
              -- If there are more than 1 events with the same campaign_id, device_id, and event_datetim, we
              -- take the first (min) session_id ordered in asc order based on event_datetime.
              min(session_id) over (
                PARTITION by device_id || '-' || campaign_id
                ORDER BY
                  event_datetime
                  RANGE BETWEEN UNBOUNDED PRECEDING
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
