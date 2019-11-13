



select count(*)
from "quasar_prod_warehouse"."public"."snowplow_sessions"
where session_duration_seconds is null

