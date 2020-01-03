import os
from pathlib import Path
import psycopg2
import sys

from utils import log, logerr

# This small library can be used as a way to export the output of any
# generic SQL to a CSV file. There's some basic sanity checking for bad
# SQL statements in the _bad_sql function, but DOUBLE CHECK YOUR QUERY
# to be sure! Use at your own risk.

# Get home directory path
home = str(Path.home())

# Psycopg2 vars.
opts = {
    'user': os.environ.get('PG_USER'),
    'host': os.environ.get('PG_HOST'),
    'port': os.environ.get('PG_PORT'),
    'password': os.environ.get('PG_PASSWORD'),
    'database': os.environ.get('PG_DATABASE'),
    'sslmode': os.environ.get('PG_SSL')
}


def _connect(opts):
    # Setup connection and log errors if can't connect.
    conn = None
    try:
        conn = psycopg2.connect(**opts)
    except psycopg2.InterfaceError as e:
        raise Exception(e)
    finally:
        return conn


def _bad_sql(sql):
    bad_sql_words = ['create', 'drop', 'delete', 'update', 'alter', 'grant']
    if any(x in sql.lower() for x in bad_sql_words):
        logerr("You wrote some destructive SQL. Exiting.")
        sys.exit(0)
    else:
        pass


def export_sql(sqlfile, exportfile):
    # Read SQL query from input file.
    f = open(sqlfile, "r")
    sql = f.read()
    # Do some basic sanity checking to ensure query doesn't break database.
    _bad_sql(sql)
    result = "COPY (" + sql + ") TO STDOUT WITH CSV HEADER DELIMITER ','"
    # Create DB connection, specify output location to home directory,
    # and export CSV & close DB connector. Finally log output file location.
    db = _connect(opts)
    cur = db.cursor()
    csv_out = home + "/" + exportfile
    with open(csv_out, "w") as outfile:
        cur.copy_expert(result, outfile)
    cur.close()
    db.close()
    log("Export file located at {}".format(csv_out))
