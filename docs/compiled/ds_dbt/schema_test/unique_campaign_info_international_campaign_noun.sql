



select count(*)
from (

    select
        campaign_noun

    from "quasar_prod_warehouse"."public"."campaign_info_international"
    where campaign_noun is not null
    group by campaign_noun
    having count(*) > 1

) validation_errors

