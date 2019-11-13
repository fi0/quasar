



select count(*)
from (

    select
        event_source

    from "quasar_prod_warehouse"."public"."phoenix_events_combined"
    where event_source is not null
    group by event_source
    having count(*) > 1

) validation_errors

