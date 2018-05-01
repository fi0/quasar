#!/bin/bash

# Remove Old Backup
echo "Deleting old Puck mongo backup."
/bin/rm -rf /var/tmp/puck-mongo-dump
echo "Old Puck mongo backup deleted."

# Source Env Variables and Dump Puck DB
source ~/.mongorc.js
mongodump -h "$PUCK_DB" -d $PUCK_DUMP_DB -u $PUCK_USER -p $PUCK_PASS --ssl --authenticationDatabase $PUCK_AUTH_DB -o /var/tmp/puck-mongo-dump
echo "Puck mongo backup complete."

# Restore to internal mongo cluster.
echo "Restoring Puck dump to internal mongo cluster."
mongorestore --drop /var/tmp/puck-mongo-dump

# ToroDB Stampede to Quasar PostgreSQL DB
sudo torodb-stampede &

# Sleep for 30 mins to allow for full sync
echo "Waiting for ToroDB sync to finish."
for i in {1..1800}
do
  echo "Been asleep for $i seconds."
  sleep 1
done

# Kill ToroDB Sync
echo "Killing ToroDB processes."
sudo /usr/bin/pkill -f torodb-stampede

# Following two commands are in process runners home directory
# to obfuscate Postgres DB name and credentials.

# Sync Local to Heroku Postgres
echo "Syncing local Postgres to Heroku Postgres data warehouse."
~/pl2h

# Refreshing Puck Postgres DB Tables
echo "Refreshing Puck derived tables."
~/petl
