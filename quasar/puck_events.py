from .database import Database
import logging
import pydash
import time


logging.getLogger().setLevel(logging.INFO)


def main():
    start_time = time.time()
    """Keep track of start time of script."""

    db = Database()

    print("Refreshing Puck JSON mat view.")
    db.query('REFRESH MATERIALIZED VIEW puck.events_json')
    logging.info('Refreshing public.path_campaign_lookup.')
    db.query('REFRESH MATERIALIZED VIEW public.path_campaign_lookup')
    logging.info('Refreshing public.phoenix_events.')
    db.query('REFRESH MATERIALIZED VIEW public.phoenix_events')
    logging.info('Refreshing public.phoenix_sessions.')
    db.query('REFRESH MATERIALIZED VIEW public.phoenix_sessions')
    logging.info('Refreshing public.device_northstar_crosswalk.')
    db.query('REFRESH MATERIALIZED VIEW public.device_northstar_crosswalk')
    db.disconnect()

    end_time = time.time()  # Record when script stopped running.
    duration = end_time - start_time  # Total duration in seconds.
    print('duration: ', duration)


if __name__ == "__main__":
    main()
