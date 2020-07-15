SELECT
	id,
	group_type_id,
	"name",
	goal,
	created_at,
	updated_at,
	city,
	external_id,
	state,
	school_id
FROM {{ source('rogue', 'groups') }}
