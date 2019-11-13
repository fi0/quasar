



select count(*)
from "quasar_prod_warehouse"."public"."phoenix_sessions_combined"
where session_duration_seconds is null

