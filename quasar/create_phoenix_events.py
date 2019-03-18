import os
import sys

from .sa_database import Database

db = Database()

# Define variables for test script. 
template = open('./data/sql/derived-tables/phoenix_events.sql', 'r').read()
data = {
     'path_campaign_lookup': os.getenv('PATH_CAMPAIGN_LOOKUP'),
     'events': os.getenv('EVENTS'),
     'phoenix_utms': os.getenv('PHOENIX_UTMS'),
     'phoenix_events': os.getenv('PHOENIX_EVENTS'),
     'phoenix_sessions': os.getenv('PHOENIX_SESSIONS'),
     'device_northstar_crosswalk': os.getenv('DEVICE_NORTHSTAR_CROSSWALK'),
     'event_lookup': os.getenv('EVENT_LOOKUP')
}

def main():
    queries = template.split(";")
    for i in queries:
        i = i.replace("\n", "")
        i = i.replace(":path_campaign_lookup", data['path_campaign_lookup'])
        i = i.replace(":events", data['events'])
        i = i.replace(":phoenix_utms", data['phoenix_utms'])
        i = i.replace(":phoenix_events", data['phoenix_events'])
        i = i.replace(":phoenix_sessions", data['phoenix_sessions'])
        i = i.replace(":device_northstar_crosswalk", data['device_northstar_crosswalk'])
        i = i.replace(":event_lookup", data['event_lookup'])
        print(i)
        if i != "":
            db.query(i)
    db.disconnect()



