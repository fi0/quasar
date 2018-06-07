import os
import pandas as pd
import sqlalchemy as sal

from .utils import QuasarException
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
            try:
                df = pd.read_sql_query(q, self.engine)
            except Exception as e:
                print(e)
            return None
        else:
            q = query
            df = pd.read_sql_query(q, self.engine)
            return df

def run_sql_file(file):
    df = DataFrameDB()
    df.run_query(file)


def run_file():
    run_sql_file('quasar/test.sql')
