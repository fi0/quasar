



select count(*)
from "quasar_prod_warehouse"."public"."snowplow_raw_events"
where referrer_host is null

