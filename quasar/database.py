import json
import os
import psycopg2

from .utils import QuasarException, logerr

# Defaults
opts = {
    'user': os.environ.get('PG_USER'),
    'host': os.environ.get('PG_HOST'),
    'port': os.environ.get('PG_PORT'),
    'password': os.environ.get('PG_PASSWORD'),
    'database': os.environ.get('PG_DATABASE'),
    'sslmode': os.environ.get('PG_SSL')
}


def _connect(opts):
    conn = None
    try:
        conn = psycopg2.connect(**opts)
    except psycopg2.InterfaceError as e:
        raise QuasarException(e)
    finally:
        return conn


class Database:

    def __init__(self, options={}):
        opts.update(options)
        self.connect()

    def connect(self):
        self.connection = _connect(opts)
        if self.connection is None:
            print("Error, couldn't connect to database with options:", opts)
        else:
            self.cursor = self.connection.cursor()

    def disconnect(self):
        self.cursor.close()
        self.connection.close()
        return self.connection

    def roll_reconnect(self):
        self.connection.rollback()
        self.disconnect()
        self.connect()

    def query(self, query):
        """Parse and run DB query.

        Return On error, raise exception and log why.
        """
        try:
            self.cursor.execute(query)
            self.connection.commit()
            try:
                results = self.cursor.fetchall()
                return results
            except psycopg2.ProgrammingError:
                results = {}
                return results
        except psycopg2.DatabaseError as e:
            print(self.cursor.query)
            raise QuasarException(e)

    def query_str(self, query, string):
        """Parse and run DB query.

        Return On error, raise exception and log why.
        """
        try:
            self.cursor.execute(query, string)
            self.connection.commit()
            try:
                results = self.cursor.fetchall()
                return results
            except psycopg2.ProgrammingError:
                results = {}
                return results
        except psycopg2.DatabaseError as e:
            print(self.cursor.query)
            raise QuasarException(e)

    def query_str_backup(self, query, string, record,
                         backup_table, event_id=None):
        """Parse and run DB query, on failure backup data.

        On query failure, assuming a single column table with data type jsonb,
        with column name "record", backup entire JSON record.

        Optional event_id for logging provided.
        """
        try:
            self.cursor.execute(query, string)
            self.connection.commit()
            try:
                results = self.cursor.fetchall()
                return results
            except psycopg2.ProgrammingError:
                results = {}
                return results
        except psycopg2.DatabaseError:
            logerr("The query: {} FAILED!".format(self.cursor.query))
            self.disconnect()
            self.connect()
            logerr("Backing up message {} to table {}.".format(event_id,
                                                               backup_table))
            self.cursor.execute(''.join(("INSERT INTO "
                                         "%s VALUES (%s)")),
                                (backup_table, json.dumps(record)))


class NorthstarDatabase(Database):

    def __init__(self, options={}):
        super().__init__(options)

    def query(self, query, record):
        """Parse and run DB query.

        Return On error, raise exception and log why.
        """
        try:
            self.cursor.execute(query)
            self.connection.commit()
            try:
                results = self.cursor.fetchall()
                return results
            except psycopg2.ProgrammingError:
                results = {}
                return results
        except psycopg2.DatabaseError:
            print(self.cursor.query)
            self.connection = _connect(opts)
            if self.connection is None:
                print("Error, couldn't connect to database with opts:", opts)
            else:
                self.cursor = self.connection.cursor()
            self.cursor.execute(''.join(("INSERT INTO "
                                         "northstar.unprocessed_users "
                                         "(northstar_record) VALUES "
                                         "(%s)")), (json.dumps(record),))
            self.connection.commit()
            print("ID {} not processed. Backing up.".format(record['id']))

    def query_str(self, query, string, record):
        """Parse and run DB query.

        Return On error, raise exception and log why.
        """
        try:
            self.cursor.execute(query, string)
            self.connection.commit()
            try:
                results = self.cursor.fetchall()
                return results
            except psycopg2.ProgrammingError:
                results = {}
                return results
        except psycopg2.DatabaseError:
            print(self.cursor.query)
            self.connection = _connect(opts)
            if self.connection is None:
                print("Error, couldn't connect to database with opts:", opts)
            else:
                self.cursor = self.connection.cursor()
            self.cursor.execute(''.join(("INSERT INTO "
                                         "northstar.unprocessed_users "
                                         "(northstar_record) VALUES "
                                         "(%s)")), (json.dumps(record),))
            self.connection.commit()
            print("ID {} not processed. Backing up.".format(record['id']))
