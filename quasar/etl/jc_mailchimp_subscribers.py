import json
import requests
from requests.auth import HTTPBasicAuth
import time
import datetime
import csv
from subprocess import Popen, PIPE, STDOUT
import MySQLdb
import MySQLdb.converters
import sys
from . import config

# Set Backfill Hours, default of from supplied argument
if not sys.argv[1]:
    backfill_hours = 2
else:
    backfill_hours = int(sys.argv[1])

# This is to track time of script
start = time.time()

# Start time in Unixtime to use internally in ETL processing
time_now = time.time()
# Set backfill to seconds and set backfill origin time to time_now - backfill_time in seconds
backfill_time = backfill_hours * 3600
origin_time = time_now - backfill_time

# MailChimp API v3.0 HTTP Simple Auth Credentials
un = config.mailchimp_api_user
pw = config.mailchimp_api_pass

# Set Initial Offset of O
member_offset = 0

# MailChimp API v3.0 Parameters to Get Subscribed Users over designated time window by paginating via "offset" parameter.
# Grabs in batches of 1000 to be nice to API. Can modify based on query times.
info = {'status':'subscribed', 'since_timestamp_opt':datetime.datetime.utcfromtimestamp(origin_time).isoformat() , 'before_timestamp_opt':datetime.datetime.utcfromtimestamp(time_now).isoformat() , 'count':1000, 'fields':'members.email_address,members.last_changed', 'offset':member_offset}

# Initialize Empty List for Total Members
total_members = []

# Get first batch of users
r = requests.get('https://us4.api.mailchimp.com/3.0/lists/f2fab1dfd4/members',auth=HTTPBasicAuth(un, pw), params=info)
member_array = r.json()

# Iterate over entire list set till no more members are returned.
while (len(member_array['members'])) > 1:
    total_members.append(member_array['members'])
    print("Total Members in Array is currently %s" % len(total_members))
    member_offset += 1000
    info = {'status':'subscribed', 'since_timestamp_opt':datetime.datetime.utcfromtimestamp(origin_time).isoformat() , 'before_timestamp_opt':datetime.datetime.utcfromtimestamp(time_now).isoformat() , 'count':1000, 'fields':'members.email_address,members.last_changed', 'offset':member_offset}
    r = requests.get('https://us4.api.mailchimp.com/3.0/lists/f2fab1dfd4/members',auth=HTTPBasicAuth(un, pw), params=info)
    member_array = r.json()

# Setup DB Connnection
conv_dict = MySQLdb.converters.conversions.copy()
conv_dict[246]=float
conv_dict[3]=int

db = MySQLdb.connect(host=config.host, #hostname
          user=config.user, #  username
          passwd=config.pw, #  password
          conv=conv_dict) # datatype conversions

cur = db.cursor()

# Iterate over entire member array and add to DB
for member in total_members:
    for submember in member:
        email = submember['email_address']
        confirm_time = submember['last_changed'].replace('T',' ').split('+')[0]
        cur.execute("INSERT IGNORE INTO users_and_activities.mailchimp_sub (email_address, confirm_time) VALUES(%s,%s)", (email,confirm_time))

db.commit()

# Close Connection in case of loop failure
cur.close()
db.close()

# Print How Long Run Took
end = time.time()
timer = end-start
print("Total processing time was %s seconds." % timer)
