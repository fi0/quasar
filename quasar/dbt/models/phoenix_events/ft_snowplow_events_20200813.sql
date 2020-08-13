SELECT
    nspt.*
FROM
    {{ source('snowplow_20200813', 'event') }} nspt
UNION
SELECT
    ospt.*
FROM
    {{ source('snowplow', 'event') }} ospt
WHERE
    ospt.collector_tstamp > '2020-07-28'
