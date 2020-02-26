SELECT DISTINCT ON (northstar_id, updated_at) *
FROM {{ ref('northstar_users_raw') }}
