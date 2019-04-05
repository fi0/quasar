import os

from sqlalchemy import create_engine, exc
from sqlalchemy.engine.url import URL
from sqlalchemy.sql import text

from .utils import log, logerr

# Setup SQL Alchemy vars.
pg_opts = {
    'drivername': os.getenv('PG_DRIVER'),
    'username': os.getenv('PG_USER'),
    'password': os.getenv('PG_PASSWORD'),
    'host': os.getenv('PG_HOST'),
    'port': os.getenv('PG_PORT'),
    'database': os.getenv('PG_DATABASE')
}

pg_ssl = os.getenv('PG_SSL')


class Database:

    def __init__(self, options={}):
        pg_opts.update(options)
        self.connect()

    def connect(self):
        # Setup SQL Alchemy postgres connection.
        try:
            engine = create_engine(URL(**pg_opts),
                                   connect_args={'sslmode': pg_ssl})
            self.conn = engine.connect()
        except exc.InterfaceError as e:
            log("Couldnt't establsh DB connection!")
            log("Error is:")
            logerr(e)

    def disconnect(self):
        self.conn.close()
        return self.conn

    def query(self, query):
        return self.conn.execute(query)

    def query_str(self, query, record):
        # Run query with string substitution using ':thisvar' SQL Alchemy
        # standard based formatting. e.g.
        # query = 'INSERT :bar into foo;', record = {bar: 'baz'}
        run_query = text(query)
        return self.conn.execute(run_query, record)