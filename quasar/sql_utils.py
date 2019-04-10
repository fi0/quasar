import os
import sys
import time

from .database import Database
from .sa_database import Database as sadb
from sqlalchemy import create_engine
from .utils import log, Duration


def sql_replace(query, datamap):
    """Used for find/replace variables in sql_run_file function based
    on a regular pattern.
    """
    # Remove any newlines.
    final_query = query.replace("\n", "")
    # Based on variables in datamap, replace ':' prepended values
    # with actual values.
    for key in datamap:
        j = ':' + key
        final_query = final_query.replace(j, datamap[key])
    return final_query


def run_sql_file(file, datamap):
    # Run SQL from file with SQL Alchemy style
    # text replacement/string substitution.
    duration = Duration()
    template = open(file, 'r').read()
    queries = template.split(";")
    db = sadb()
    for i in queries:
        i = sql_replace(i, datamap)
        # If query is empty, will throw an error.
        if i != "":
            log("Running query:")
            log(i)
            db.query(i)
    db.disconnect()
    duration.duration()


def run_sql_file_raw(file):
    # Corrolary function to run_sql_file that doesn't require
    # any string replacements, and can run from a file with no var subs.
    duration = Duration()
    template = open(file, 'r').read()
    queries = template.split(";")
    db = sadb()
    for i in queries:
        # If query is empty, will throw an error.
        if i != "":
            log("Running query:")
            log(i)
            db.query(i)
    db.disconnect()
    duration.duration()


def refresh_materialized_view(view):
    db = Database()
    start_time = time.time()
    """Keep track of start time of script."""

    db.query("REFRESH MATERIALIZED VIEW " + view)
    db.disconnect()

    end_time = time.time()  # Record when script stopped running.
    duration = end_time - start_time  # Total duration in seconds.
    print('duration: ', duration)
