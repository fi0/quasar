# About this script, it will:
# - It is non-destructive. It doesn't delete and it doesn't import
#   into a production table.
# - Use SQL Alchemy as its ORM
# - Stream and bulk import 1000 events at a time.
# - import into a holding table with name pattern: event_log_import_YYYYMMDD
# - Import of the events into the actual production table is expected to
#   be handled manually (SQL) by a data engineer.


# import necessary libraries

# Connect and create required holding table in cio schema

# read the file with the cio payloads 1000 lines at a time

# bulk insert events in to holding table
