




select count(*)
from (
    select northstar_id as id from "quasar_prod_warehouse"."public"."phoenix_events_combined"
) as child
left join (
    select id as id from "quasar_prod_warehouse"."public"."users"
) as parent on parent.id = child.id
where child.id is not null
  and parent.id is null

