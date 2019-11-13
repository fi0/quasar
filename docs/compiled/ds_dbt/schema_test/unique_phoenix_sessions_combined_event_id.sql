



select count(*)
from (

    select
        event_id

    from "quasar_prod_warehouse"."public"."phoenix_sessions_combined"
    where event_id is not null
    group by event_id
    having count(*) > 1

) validation_errors

