from .sa_database import Database
from .utils import Duration, log

db = Database()
duration = Duration()


def import_records(table):
    record = {
        'base_table' : table
        'staging_table': table + '_staging'
    }
    query = ''.join(("INSERT INTO :base_table "
                     "SELECT * FROM :staging_table"))
    db.query_str(query, record)


def truncate_staging(table):
    record = {
        'staging_table: 'table + '_staging'
    }
    query = "TRUNCATE TABLE :staging_table"
    db.query_str(query, record)


def cio_import():
    tables = ['cio.customer_event', 
              'cio.email_event',
              'cio.email_sent',
              'cio.email_bounced']
    for table in tables:
        log("Importing records for table {}.".format(table))
        import_records(table)
        staging_table = table + '_staging'
        log("Truncating table {}.".format(staging_table))
        truncate_staging(staging_table)
