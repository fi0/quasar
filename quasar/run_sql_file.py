import os
import pandas as pd
import sys

from sqlalchemy import create_engine


class DataFrameDB:
    def __init__(self, opts={}):

        self.opts = {
            'user': os.environ.get('PG_USER'),
            'host': os.environ.get('PG_HOST'),
            'password': os.environ.get('PG_PASSWORD'),
            'db': os.environ.get('PG_DATABASE'),
            'port': str(os.environ.get('PG_PORT')),
            'use_unicode': True,
            'charset': 'utf8'
        }

        self.engine = create_engine(
            'postgresql+psycopg2://' +
            self.opts['user'] +
            ':' +
            self.opts['password'] +
            '@' +
            self.opts['host'] +
            ':' +
            self.opts['port'] +
            '/' +
            self.opts['db'])

    def run_query(self, query):
        if '.sql' in query:
            q = open(query, 'r').read()
        else:
            q = query
        try:
            pd.read_sql_query(q, self.engine)
        except Exception as e:
            success = ''.join(("This result object does not return rows. "
                               "It has been closed automatically."))

            if str(e) == success:
                print("From Team Storm Engineers:")
                print("The query ran successfully if you're reading this.")
                print("We'll make this more graceful in the future.")
                sys.exit(0)
            else:
                print(e)
                sys.exit(1)


def run_sql_file(file):
    df = DataFrameDB()
    df.run_query(file)
