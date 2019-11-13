



select count(*)
from "quasar_prod_warehouse"."public"."snowplow_sessions"
where num_pages_views is null

