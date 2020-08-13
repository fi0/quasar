SELECT
    nspt.*
FROM
    {{ source('snowplow_20200813', 'snowplow_event') }} nspt
UNION
SELECT
    ospt.*
FROM
    {{ source('snowplow', 'snowplow_event') }} ospt
WHERE
    ospt.collector_tstamp > '2020-07-28'
