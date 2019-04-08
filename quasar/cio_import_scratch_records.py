from .sa_database import Database
from .utils import Duration, log

db = Database()
duration = Duration()


def import_records_event(table):
    # Import records from cio staging tables that are populated
    # by the cio consumer into primary queried tables that have
    # event_type based primary key.
    scratch = table + '_scratch'
    query = ''.join(("INSERT INTO {} SELECT * FROM {} "
                     "ON CONFLICT (email_id, customer_id, timestamp, "
                     "event_type) DO NOTHING"
                     "")).format(table, scratch)
    db.query(query)

def import_records(table):
    # Import records from cio staging tables that are populated
    # by the cio consumer into primary queried tables.
    scratch = table + '_scratch'
    query = ''.join(("INSERT INTO {} SELECT * FROM {} "
                     "ON CONFLICT (email_id, customer_id, timestamp) "
                     "DO NOTHING"
                     "")).format(table, scratch)
    db.query(query)

def truncate_scratch(table):
    # Truncate staging tables so consumer can resume updating
    # tables after ingestion.
    scratch = table + '_scratch'
    query = "TRUNCATE TABLE {}".format(scratch)
    db.query(query)


def cio_import():
    # List of cio tables to process.
    tables = ['cio.email_sent', 'cio.email_bounced']
    event_tables = ['cio.customer_event', 'cio.email_event']
    for table in tables:
        log("Importing records for table {}.".format(table))
        import_records(table)
        scratch = table + '_scratch'
        log("Truncating table {}.".format(scratch))
        truncate_scratch(table)
    for table in event_tables:
        log("Importing records for table {}.".format(table))
        import_records_event(table)
        scratch = table + '_scratch'
        log("Truncating table {}.".format(scratch))
        truncate_scratch(table)    
    db.disconnect()
    duration.duration()
