import pydash
import time

from .database import Database
from .utils import log


def main():
    start_time = time.time()
    """Keep track of start time of script."""

    db = Database()

    log("Refreshing Puck JSON mat view.")
    db.query('REFRESH MATERIALIZED VIEW puck.events_json')
    log('Refreshing public.path_campaign_lookup.')
    db.query('REFRESH MATERIALIZED VIEW public.path_campaign_lookup')
    log('Refreshing public.phoenix_events.')
    db.query('REFRESH MATERIALIZED VIEW public.phoenix_events')
    log('Refreshing public.phoenix_sessions.')
    db.query('REFRESH MATERIALIZED VIEW public.phoenix_sessions')
    log('Refreshing public.device_northstar_crosswalk.')
    db.query('REFRESH MATERIALIZED VIEW public.device_northstar_crosswalk')
    db.disconnect()

    end_time = time.time()  # Record when script stopped running.
    duration = end_time - start_time  # Total duration in seconds.
    print('duration: ', duration)


if __name__ == "__main__":
    main()
