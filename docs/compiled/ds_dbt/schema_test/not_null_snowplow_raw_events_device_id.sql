



select count(*)
from "quasar_prod_warehouse"."public"."snowplow_raw_events"
where device_id is null

