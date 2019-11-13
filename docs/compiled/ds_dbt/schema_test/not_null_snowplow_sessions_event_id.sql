



select count(*)
from "quasar_prod_warehouse"."public"."snowplow_sessions"
where event_id is null

