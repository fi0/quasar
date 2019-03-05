import os
import time

from .database import Database
from .refresh_dms import refresh_dms
from .sql_utils import run_sql_file


def create():
    """(Re)create materialized views: campaign_info_all, campaign_info,
    campaign_info_international.
    """
    run_sql_file('./data/sql/derived-tables/campaign_info.sql')


def main():
    start_time = time.time()
    """Keep track of start time of script."""

    db = Database()

    db.query('REFRESH MATERIALIZED VIEW ft_dosomething_rogue.campaign_info_all')
    db.query('REFRESH MATERIALIZED VIEW public.campaign_info')
    db.query('REFRESH MATERIALIZED VIEW public.campaign_info_international')
    db.disconnect()

    end_time = time.time()  # Record when script stopped running.
    duration = end_time - start_time  # Total duration in seconds.
    print('duration: ', duration)


if __name__ == "__create__":
    create()

if __name__ == "__main__":
    main()
