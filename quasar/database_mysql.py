import MySQLdb
import MySQLdb.converters

from .config import config
from .utils import QuasarException


def dec_to_float_converter():
    converter = MySQLdb.converters.conversions.copy()
    converter[246] = float
    return converter


def _connect(opts):
    conn = None
    try:
        conn = MySQLdb.connect(**opts)
    except MySQLdb.InterfaceError as e:
        raise QuasarException(e)
    finally:
        return conn


class Database:

    def __init__(self, options={}):

        # Defaults
        opts = {
            'user': config.MYSQL_USER,
            'host': config.MYSQL_HOST,
            'port': config.MYSQL_PORT,
            'passwd': config.MYSQL_PASSWORD,
            'db': config.MYSQL_DATABASE,
            'ssl': config.MYSQL_SSL,
            'use_unicode': True,
            'charset': 'utf8'
        }

        opts.update(options)

        self.connection = _connect(opts)
        if self.connection is None:
            print("Error, couldn't connect to database with options:", opts)
        else:
            self.cursor = self.connection.cursor()
            if 'conv' in opts:
                self.cursor = self.connection.cursor(
                    MySQLdb.cursors.DictCursor)

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
            results = self.cursor.fetchall()
            return results
        except MySQLdb.DatabaseError as e:
            raise QuasarException(e)

    def query_str(self, query, string):
        """Parse and run DB query.

        Return On error, raise exception and log why.
        """
        try:
            self.cursor.execute(query, string)
            self.connection.commit()
            results = self.cursor.fetchall()
            return results
        except MySQLdb.DatabaseError as e:
            raise QuasarException(e)
