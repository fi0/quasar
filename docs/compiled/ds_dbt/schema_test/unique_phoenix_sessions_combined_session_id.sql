



select count(*)
from (

    select
        session_id

    from "quasar_prod_warehouse"."public"."phoenix_sessions_combined"
    where session_id is not null
    group by session_id
    having count(*) > 1

) validation_errors

