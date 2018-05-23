import sys
import os
import datetime as dt
import pandas as pd
import sqlalchemy as sal
import psycopg2 as psy

from .config import config
from .utils import QuasarException
from sqlalchemy import create_engine
from slackclient import SlackClient


class DataFrameDB:
    def __init__(self, opts={}):

        self.opts = {
            'user': config.PG_USER,
            'host': config.PG_HOST,
            'password': config.PG_PASSWORD,
            'db': config.PG_DATABASE,
            'port': str(config.PG_PORT),
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
        df = pd.read_sql_query(q, self.engine)
        return df


class ETLMonitoring:
    def __init__(self):
        db_opts = {}
        self.db = DataFrameDB(db_opts)

        self.etl_queries = {
            'raw_northstar':
                'SELECT count(*) FROM northstar.users',
            'raw_rogue_signups':
                'SELECT count(*) FROM rogue.signups',
            'raw_rogue_posts':
                'SELECT count(*) FROM rogue.posts',
            'raw_puck_events':
                'SELECT count(*) FROM puck.events',
            'raw_cio_emails':
                'SELECT count(*) FROM cio.email_events',
            'raw_cio_customers':
                'SELECT count(*) FROM cio.customer_events',
            'derived_user_count':
                'SELECT count(*) FROM public.users',
            'derived_user_distinct_user_count':
                'SELECT count(distinct u.northstar_id) '
                'FROM public.users u',
            'derived_active_user_count':
                "SELECT count(*) FROM public.users u " 
                "WHERE u.active_member = true",
            'derived_ca_table_count':
                'SELECT count(*) FROM public.campaign_activity c',
            'derived_ca_post_count':
                'SELECT count(distinct c.post_id) '
                'FROM public.campaign_activity c',
            'derived_puck_events':
                'SELECT count(*) FROM public.phoenix_events',
            'derived_puck_sessions':
                'SELECT count(*) FROM public.phoenix_sessions'
        }

    @staticmethod
    def teardown(self):
        self.db.disconnect(self)

    @staticmethod
    def construct_query_dict(description, query, query_set=None):
        if query_set is None:
            query_set = {}

        query_set[description] = query

        return query_set

    def get_value(self, query):
        try:
            value = self.db.run_query(query)
            out = int(value.iloc[0])
            return out
        except:
            out = str(QuasarException(sys.exc_info()[0]))
            return out

    def compile_statuses(self, queries):
        values = []
        descriptions = []
        ts = []
        table = []

        for query in queries.values():
            value = self.get_value(query)
            values.append(value)
            time = dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            ts.append(time)
            this_table = query.split('FROM')[1].split(' ')[1]
            table.append(this_table)

        for description in queries.keys():
            descriptions.append(description)

        out = pd.DataFrame(
            {'query': descriptions,
             'output': values,
             'table': table,
             'timestamp': ts
             })
        return out

    def extract_latest_value(self, table, desc):
        max_query = \
            "SELECT  \
                m.output  \
            FROM public.monitoring m  \
            INNER JOIN ( \
                SELECT \
                    t.table, \
                    t.query,  \
                    max(t.timestamp) AS max_created \
                FROM public.monitoring t \
                WHERE t.table = '" + table + "' AND t.query = '" + desc + "' \
                    ) tim ON tim.max_created = m.timestamp \
            WHERE m.table = '" + table + "'  \
            AND m.query = '" + desc + "';"
        value = self.get_value(max_query)
        return value

    def extract_second_latest_value(self, table, desc):
        max_2_query = \
            "SELECT \
                m.output \
            FROM public.monitoring m \
            INNER JOIN \
                (SELECT \
                    max(t.timestamp) AS ts_2 \
                FROM public.monitoring t \
                WHERE t.table = '" + table + "' \
                AND t.query = '" + desc + "' \
                AND \
                t.timestamp < (SELECT max(t1.timestamp)  \
                                FROM public.monitoring t1 \
                                WHERE t1.table = '" + table + "'  \
                                AND t1.query = '" + desc + "') \
                ) ts2 ON ts2.ts_2 = m.timestamp \
            WHERE m.table = '" + table + "' AND m.query = '" + desc + "';"
        value = self.get_value(max_2_query)
        return value

    def compare_distinct(self):
        query = \
            "SELECT  \
               m.query,  \
               m.output  \
            FROM public.monitoring m   \
            WHERE m.table = 'quasar.users' \
            AND m.timestamp = (SELECT max(t1.timestamp)  \
                               FROM public.monitoring t1 \
                               WHERE t1.query = 'user_count') \
            OR m.timestamp = (SELECT max(t1.timestamp)  \
                               FROM public.monitoring t1 \
                               WHERE t1.query = 'user_distinct_user_count')"
        frame = self.db.run_query(query)
        user_count = \
            int(frame[frame['query'] == 'user_count']['output'])
        distinct_count = \
            int(frame[frame['query'] == 'user_distinct_user_count']['output'])

        if user_count == distinct_count:
            message = \
                "*Passed* - Distinct users equals " \
                "number of rows in public.users"
        else:
            message = \
                "*Failed* - Distinct users does not equal " \
                "number of rows in public.users"

        return message

    def compare_latest_values(self, table, desc):
        latest_value = self.extract_latest_value(table, desc)
        second_latest_value = self.extract_second_latest_value(table, desc)

        try:
            if latest_value > second_latest_value:
                message = "*Passed* - Latest Count = " + \
                          str(latest_value) + \
                          " Previous Value = " + \
                          str(second_latest_value) +  \
                          ", Count increased by " + \
                          str(latest_value - second_latest_value)
            elif latest_value == second_latest_value:
                message = "*Failed* - Count Unchanged," \
                          " Latest Count = " + \
                          str(latest_value) + \
                          " Previous Value = " + \
                          str(second_latest_value)
            elif latest_value < second_latest_value:
                message = "*Failed* - Count Decreased," \
                          " Latest Count = " + \
                          str(latest_value) + \
                          " Previous Value = " + \
                          str(second_latest_value)
            else:
                message = '*Failed* - Unspecified Error'
        except:
            message = str(QuasarException(sys.exc_info()[0]))
        report = message + ": " + table + " " + desc

        return report

    def write_to_monitoring_table(self, table):
        table.to_sql(
            name='monitoring',
            con=self.db.engine,
            schema='public',
            if_exists='append',
            index=False,
            dtype={'timestamp': sal.types.DATETIME(),
                   'output': sal.types.INTEGER(),
                   'query': sal.types.INTEGER(),
                   'table': sal.types.NVARCHAR(length=64)
                   }
        )

    @staticmethod
    def send_message(message):
        sc = SlackClient(config.ETLMON_SLACKBOT_TOKEN)
        sc.api_call(
            "chat.postMessage",
            channel="#storm-watch",
            text=message
        )

    def monitor(self):
        frame = self.compile_statuses(self.etl_queries)
        self.write_to_monitoring_table(frame)

        for index, row in frame.iterrows():
            this_table = row['table']
            this_desc = row['query']
            this_message = self.compare_latest_values(this_table, this_desc)
            self.send_message(this_message)

        this_message = self.compare_distinct()
        self.send_message(this_message)


def run_monitoring():
    mon = ETLMonitoring()
    mon.monitor()
