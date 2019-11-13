



select count(*)
from "quasar_prod_warehouse"."public"."snowplow_phoenix_events"
where session_id is null

