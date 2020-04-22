WITH device_campaign_session_ref AS
  (SELECT dc.device_id,
          dc.campaign_id,
          dc.session_id,
          dc.min_view_datetime,
          CASE
              WHEN s.session_referrer_host='' THEN NULL
              ELSE s.session_referrer_host
          END AS session_referrer_host,
          s.session_utm_source,
          s.session_utm_campaign,
          dc.min_intent_datetime
   FROM
     (--was the device_campaign_session table
 WITH device_campaign_all AS
        (SELECT device_id,
                campaign_id,
                event_name,
                event_datetime
         FROM public.phoenix_events_combined
         WHERE campaign_id IS NOT NULL ),
      device_campaign_dates AS
        (SELECT device_id,
                campaign_id,
                min(event_datetime) AS min_view_datetime,
                min(CASE
                        WHEN event_name='phoenix_clicked_signup' THEN event_datetime
                    END) AS min_intent_datetime
         FROM device_campaign_all
         GROUP BY 1,
                  2) SELECT DISTINCT d.device_id,
                                     d.campaign_id,
                                     e.session_id,
                                     d.min_view_datetime,
                                     d.min_intent_datetime
      FROM device_campaign_dates d
      JOIN public.phoenix_events_combined e ON (d.device_id=e.device_id
                                                AND d.campaign_id=e.campaign_id
                                                AND d.min_view_datetime=e.event_datetime)) dc --Join w session table to get referring sources

   JOIN public.phoenix_sessions_combined s ON (dc.session_id=s.session_id))
SELECT device_id,
       campaign_id,
       session_id,
       min_view_datetime,
       session_referrer_host,
       session_utm_source,
       session_utm_campaign,
       min_intent_datetime
FROM device_campaign_session_ref

