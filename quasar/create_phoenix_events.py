import os
import sys

from .sql_utils import run_sql_file

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
    run_sql_file('./data/sql/derived-tables/phoenix_events.sql', data)




