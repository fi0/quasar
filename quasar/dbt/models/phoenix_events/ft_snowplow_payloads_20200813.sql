SELECT
    *
FROM
    {{ source('snowplow_20200813', 'snowplow_event') }} nspt
UNION
SELECT
    *
FROM
    {{ source('snowplow', 'snowplow_event') }} ospt
WHERE
    osp.collector_tstamp > '2020-07-28'
