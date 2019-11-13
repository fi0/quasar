



select count(*)
from "quasar_prod_warehouse"."public"."snowplow_phoenix_events"
where referrer_host is null

