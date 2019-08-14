import csv
import os
import sys

from .sql_utils import run_sql_file
from .utils import log


def remove_northstar(nsid):
    # Removes Northstar user data for GDPR compliance.
    data = {'users': os.getenv('NORTHSTAR_USERS'), 'nsid': nsid}
    run_sql_file('./data/sql/misc/gdpr_northstar_removal.sql', data)


def remove_cio(nsid):
    # Removes CIO user data for GDPR compliance.
    data = {'customer_event': os.getenv('CIO_CUSTOMER_EVENT'),
            'email_bounced': os.getenv('CIO_EMAIL_BOUNCED'),
            'email_event': os.getenv('CIO_EMAIL_EVENT'),
            'email_sent': os.getenv('CIO_EMAIL_SENT'),
            'event_log': os.getenv('CIO_EVENT_LOG'),
            'nsid': nsid}
    run_sql_file('./data/sql/misc/gdpr_cio_removal.sql', data)


def gdpr_from_file():
    with open(sys.argv[1]) as csvfile:
        ids = csv.reader(csvfile, delimiter=',')
        for id in ids:
            # First line might contain "id" as column name
            if id[0] == 'id':
                pass
            else:
                log("Removing Northstar ID {}".format(id))
                remove_northstar(id[0])
                remove_cio(id[0])
