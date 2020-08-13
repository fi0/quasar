SELECT
    *
FROM
    {{ source('snowplow_20200813', 'event') }} nspt
UNION
SELECT
    *
FROM
    {{ source('snowplow', 'event') }} ospt
WHERE
    osp.collector_tstamp > '2020-07-28'
