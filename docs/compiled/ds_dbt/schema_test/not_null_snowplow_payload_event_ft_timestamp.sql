



select count(*)
from "quasar_prod_warehouse"."public"."snowplow_payload_event"
where ft_timestamp is null

