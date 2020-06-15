import os

from sqlalchemy import (create_engine, exc, MetaData,
                        Table, Column, DateTime, String)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.engine.url import URL

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
        self._connect()

    def _connect(self):
        # Setup SQL Alchemy postgres connection.
        try:
            self.engine = create_engine(URL(**pg_opts),
                                        connect_args={'sslmode': pg_ssl})
            self.conn = self.engine.connect()
            self.meta = MetaData()
            # Define event_log table.
            self.event_log = Table('event_log',
                                    self.meta,
                                    Column('event', JSONB),
                                    Column('timestamp',
                                        DateTime(timezone=True)),
                                    Column('event_id', String),
                                    schema='cio')
            # Initialize tables.
            self.meta.create_all(self.engine)
        except exc.InterfaceError as e:
            log("Couldn't establish DB connection!")
            log("Error is:")
            logerr(e)

    def insert_event(self, data, time, event_id):
        # Insert event JSON and timestamp values.
        query = self.event_log.insert().values(event=data, timestamp=time, event_id=event_id)
        self.conn.execute(query)

    def disconnect(self):
        self.conn.close()
        return self.conn
