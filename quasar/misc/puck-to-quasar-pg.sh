#!/bin/bash

# Remove Old Backup
echo "Deleting old Puck mongo backup."
/bin/rm -rf /var/tmp/puck-mongo-dump
echo "Old Puck mongo backup deleted."

# Source Env Variables and Dump Puck DB
source ~/.mongorc.js
mongodump -h $PUCK_DB:$PUCK_PORT -d $PUCK_AUTH_DB -u $PUCK_USER -p $PUCK_PASS -o /var/tmp/puck-mongo-dump
echo "Puck mongo backup complete."

# Restore to internal mongo cluster.
echo "Restoring Puck dump to internal mongo cluster."
mongorestore --drop -h mongo2.d12g.co /var/tmp/puck-mongo-dump

# ToroDB Stampede to Quasar PostgreSQL DB
sudo torodb-stampede &

# Sleep for 10 mins to allow for full sync
echo "Waiting for ToroDB sync to finish."
for i in {1..600}
do
  echo "Been asleep for $i seconds."
  sleep 1
done

# Kill ToroDB Sync
echo "Killing ToroDB processes."
sudo /usr/bin/pkill -f torodb-stampede

# Refreshing Puck Postgres DB Tables
echo "Refreshing Puck derived tables."
/usr/bin/psql -h quasar-pg.c9ajz690mens.us-east-1.rds.amazonaws.com -U torodb quasar -a -f puck_etl.sql
