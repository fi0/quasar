SELECT
	id,
	"name",
	created_at,
	updated_at,
	filter_by_state
FROM {{ source('rogue', 'group_types') }}
