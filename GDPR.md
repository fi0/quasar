## Instructions for GDPR Record Removal

These steps can't be run as a normal Jenkins job, for security reasons, as well as making sure we have a human brain for validation of removing records.

* Get CSV of Northstar ID's. The CSV should have a single column of values, with only `id` or no value as the first line. Each line should be a separate Northstar ID value.
* Login to a runtime environment that can connect to the Quasar Production environment (recommended is one of compute nodes, running the commands locally can take a while for a large list of ID's).
* Run the command `gdpr /path/to/file` and monitor the output for validation that records have been removed.