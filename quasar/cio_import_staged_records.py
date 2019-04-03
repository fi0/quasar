from .sa_database import Database
from .utils import Duration, log

db = Database()
duration = Duration()


def import_records(table):
    # Import records from cio staging tables that are populated
    # by the cio consumer into primary queried tables.
    record = {
        'base_table': table,
        'staging_table': table + '_staging'
    }
    query = ''.join(("INSERT INTO :base_table "
                     "SELECT * FROM :staging_table"))
    db.query_str(query, record)


def truncate_staging(table):
    # Truncate staging tables so consumer can resume updating
    # tables after ingestion.
    record = {
        'staging_table: 'table + '_staging'
    }
    query = "TRUNCATE TABLE :staging_table"
    db.query_str(query, record)


def cio_import():
    # List of cio tables to process.
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
