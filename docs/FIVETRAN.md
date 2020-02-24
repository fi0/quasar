## How to force a Fivetran refresh
* Login to Fivetran and navigate to https://fivetran.com/dashboard/connectors
* Make sure you pick the correct data warehouse from the upper left hand dropdown.
* Click on the connector you want to sync immediately.
* Click on the "Sync Now" button in the upper right hand corner, _only_ if a sync isn't currently running.


## Fivetran Refresh Schedule

Data Source | Refresh Cadence | Notes
----------- | --------------- | -----
Gambit | 1 Hour |
Northstar | 5 minutes | Northstar cadence is set to 5 minutes vs other data sources since we perform DBT snapshots to capture user change diffs to create a log table.
Rogue | 1 Hour |
Snowplow | 1 Hour |

The refresh cadence is the same in Quasar Prod or QA environments.

## Fivetran Connector Certificate Troubleshooting
Occasionally during certificate rotations or setting up new connectors, we need to manually verify the certificate trust. Unfortunately, there are different certs to trust for different vendors. Here are the ones we know about so far:

Amazon RDS:
* Click the certificate that corresponds to the 2nd tier (non-root/sub) domain trust.

MongoDB (LetsEncrypt based):
* Click the certificate that corresponds to the 1st tier (root) domain trust.