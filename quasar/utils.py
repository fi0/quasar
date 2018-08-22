from datetime import datetime as dt
from .database import Database
import logging
import re
import time

# DoSomething Helper Functions - Code Reused Across Lots of our ETL Scripts

# String Parser


def strip_str(base_value):
    """Convert value to string and strips special characters.

    None becomes empty string
    """
    base_string = str(base_value)
    if base_string == 'None':
        return ''
    else:
        strip_special_chars = re.sub(r'[()<>/"\,\'\\]', '', base_string)
        return str(strip_special_chars)


def now_minus_hours(hours):
    """Returns time x hours ago"""
    if hours is None:
        return None
    else:
        start_time = int(time.time()) - (int(hours) * 3600)
        return dt.fromtimestamp(start_time).isoformat()


def unixtime_to_isotime(unixtime):
    return dt.fromtimestamp(unixtime).isoformat()


def refresh_materialized_view(view):
    db = Database()
    start_time = time.time()
    """Keep track of start time of script."""

    db.query("REFRESH MATERIALIZED VIEW " + view)
    db.disconnect()

    end_time = time.time()  # Record when script stopped running.
    duration = end_time - start_time  # Total duration in seconds.
    print('duration: ', duration)


class Duration:
    """Simple duration tracker.

    Object starts tracking time when instantiated, and then when
    duration function is called records and prints then returns
    duration time in seconds.
    """
    def __init__(self):
        self.start_time = time.time()

    def duration(self):
        run_time = time.time() - self.start_time
        logging.info("Duration in seconds: ".format(run_time))
        return run_time


class QuasarException(Exception):
    """Donated exception handling code by Rob Spectre.

    This logs any error message we need to pass in.
    """

    def __init__(self, message):
        """Log errors with formatted messaging."""
        logging.error("ERROR: {0}".format(message))
        pass
