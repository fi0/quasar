import os

from .sql_utils import run_sql_file, refresh_materialized_view

data = {
    'path_campaign_lookup': os.getenv('PATH_CAMPAIGN_LOOKUP'),
    'events': os.getenv('EVENTS'),
    'phoenix_utms': os.getenv('PHOENIX_UTMS'),
    'phoenix_events': os.getenv('PHOENIX_EVENTS'),
    'phoenix_sessions': os.getenv('PHOENIX_SESSIONS'),
    'device_northstar_crosswalk': os.getenv('DEVICE_NORTHSTAR_CROSSWALK'),
    'event_lookup': os.getenv('EVENT_LOOKUP')
}


def create():
    run_sql_file('./data/sql/derived-tables/phoenix_events.sql', data)


def refresh():
    refresh_materialized_view('public.path_campaign_lookup')
    refresh_materialized_view(data['phoenix_utms'])
    refresh_materialized_view('public.phoenix_events')
    refresh_materialized_view('public.public.phoenix_sessions')
    refresh_materialized_view('public.device_northstar_crosswalk')


if __name__ == '__create__':
    create()

if __name__ == '__refresh__':
    refresh()
