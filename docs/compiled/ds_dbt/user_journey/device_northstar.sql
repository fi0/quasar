--All Device ID - Northstar ID Combinations
WITH devices_all AS (
    SELEct device_id, northstar_id
    FROM "quasar_prod_warehouse"."public"."phoenix_events_combined"
    GROUP BY device_id, northstar_id
)
,
--Devices purely Anonymous (Remove Devices ever associated with NSIDs)
--If a DeviceID was both logged-in and logged-out, it will be removed from the anonymous DeviceID pool
devices_an AS (
    SELECt device_id
    FROM devices_all
    WHERE northstar_id IS NULL
    EXCEPT
    SELECT device_id
    FROM devices_all
    WHERE northstar_id IS NOT NULL
)

SELECT device_id, northstar_id
FROM devices_all
UNION ALL
SELECT device_id, NULL
FROM devices_an;