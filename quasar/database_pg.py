import json
import psycopg2

from .config import config
from .utils import QuasarException

# Defaults
opts = {
    'user': config.PG_USER,
    'host': config.PG_HOST,
    'port': config.PG_PORT,
    'password': config.PG_PASSWORD,
    'database': config.PG_DATABASE,
    'sslmode': config.PG_SSL
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

        self.connection = _connect(opts)
        if self.connection is None:
            print("Error, couldn't connect to database with options:", opts)
        else:
            self.cursor = self.connection.cursor()

    def disconnect(self):
        self.cursor.close()
        self.connection.close()
        return self.connection

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
