import os
import sys

from sqlalchemy import create_engine
from sqlalchemy.engine.url import URL
from sqlalchemy.sql import text

# Setup SQL Alchemy vars.
pg_vars = {
    'drivername': os.getenv('PG_DRIVER'),
    'username': os.getenv('PG_USER'),
    'password': os.getenv('PG_PASSWORD'),
    'host': os.getenv('PG_HOST'),
    'port': os.getenv('PG_PORT'),
    'database': os.getenv('PG_DATABASE')
}

pg_ssl = os.getenv('PG_SSL')

# Setup SQL Alchemy postgres connection.
engine = create_engine(URL(**pg_vars),
                       connect_args={'sslmode': pg_ssl})
conn = engine.connect()


# Define variables for test script. 
template = open('./data/sql/derived-tables/phoenix_events_sub.sql', 'r').read()
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
            conn.execute(i)



