
    
    



select count(*) as validation_errors
from "quasar_prod_warehouse"."public"."phoenix_events_combined"
where path is null

