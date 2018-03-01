import psycopg2

from .config import config
from .utils import QuasarException


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

        # Defaults
        opts = {
            'user': config.PG_USER,
            'host': config.PG_HOST,
            'port': config.PG_PORT,
            'password': config.PG_PASSWORD,
            'database': config.PG_DATABASE,
            'sslmode': config.PG_SSL
        }

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
            except psycopg2.ProgrammingError as e:
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
            except psycopg2.ProgrammingError as e:
                results = {}
                return results
        except psycopg2.DatabaseError as e:
            print(self.cursor.query)
            raise QuasarException(e)

