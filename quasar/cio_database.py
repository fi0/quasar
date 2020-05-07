import os

from sqlalchemy import (bindparam, create_engine, exc, MetaData,
    Table, Column, Integer, DateTime, String, Text)
from sqlalchemy.dialects.postgresql.json import JSONB
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
        self._connect()

    def _connect(self):
        # Setup SQL Alchemy postgres connection.
        try:
            self.engine = create_engine(URL(**pg_opts),
                            connect_args={'sslmode': pg_ssl})
            self.conn = engine.connect()
            self.meta = MetaData()
            # Define each Customer.io table with 1 table/private function.
            self._create_customer_event_table()
            self._create_email_event_table()
            # Once all tables are defined, initialize them.
            self.meta.create_all(engine)
        except exc.InterfaceError as e:
            log("Couldnt't establsh DB connection!")
            log("Error is:")
            logerr(e)

    def _create_customer_event_table(self):
            self.customer_event = Table('customer_event_scratch', self.meta,
                Column('email_id', String),
                Column('customer_id', String),
                Column('email_address', String),
                Column('template_id', Integer),
                Column('event_id', String),
                Column('timestamp', DateTime(timezone=True)),
                Column('event_type', String),
                schema='cio')

    def _create_email_event_table(self):
            self.email_event = Table('email_event_scratch', self.meta,
                Column('email_id', String),
                Column('customer_id', String),
                Column('email_address', String),
                Column('template_id', Integer),
                Column('subject', Text),
                Column('href', Text),
                Column('link_id', String),
                Column('event_id', String),
                Column('timestamp', DateTime(timezone=True)),
                Column('event_type', String),
                schema='cio')

    def disconnect(self):
        self.conn.close()
        return self.conn

