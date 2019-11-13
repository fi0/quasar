



select count(*)
from (

    select
        session_id

    from "quasar_prod_warehouse"."public"."snowplow_sessions"
    where session_id is not null
    group by session_id
    having count(*) > 1

) validation_errors

