



select count(*)
from "quasar_prod_warehouse"."public"."snowplow_base_event"
where device_id is null
