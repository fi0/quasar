SELECT
    *
FROM
    {{ source('cio', 'event_log') }} cel
