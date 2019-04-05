from .sa_database import Database
from .utils import Duration, log

db = Database()
duration = Duration()


def import_records(table):
    # Import records from cio staging tables that are populated
    # by the cio consumer into primary queried tables.
    scratch = table + '_scratch'
    query = ''.join(("INSERT INTO {} "
                     "SELECT * FROM {}"
                     "")).format(table, scratch)
    # db.query(query)
    print(query)


def truncate_scratch(table):
    # Truncate staging tables so consumer can resume updating
    # tables after ingestion.
    scratch = table + '_scratch'
    query = "TRUNCATE TABLE {}".format(scratch)
    # db.query(query)
    print(query)


def cio_import():
    # List of cio tables to process.
    tables = ['cio.customer_event',
              'cio.email_event',
              'cio.email_sent',
              'cio.email_bounced']
    for table in tables:
        log("Importing records for table {}.".format(table))
        import_records(table)
        scratch = table + '_scratch'
        log("Truncating table {}.".format(scratch))
        truncate_scratch(table)
