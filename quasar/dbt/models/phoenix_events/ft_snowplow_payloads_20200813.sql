SELECT
    nspt.event_id,
    nspt._fivetran_synced,
    nspt.payload
FROM
    {{ source('snowplow_20200813', 'snowplow_event') }} nspt
UNION
SELECT
    ospt.event_id,
    ospt._fivetran_synced,
    ospt.payload
FROM
    {{ source('snowplow', 'snowplow_event') }} ospt
