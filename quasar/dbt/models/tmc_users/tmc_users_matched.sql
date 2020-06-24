SELECT
    *
FROM
    {{ source('tmc', 'tmc_users_matched') }}
