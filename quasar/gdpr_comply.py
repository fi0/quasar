import csv
import os
import sys

from .sql_utils import run_sql_file
from .utils import log


def remove_northstar():
    # Removes Northstar user data for GDPR compliance.
    data = {'users': os.getenv('NORTHSTAR_FT_SCHEMA'),
            'legacy_users': os.getenv('NORTHSTAR_USERS')}
    run_sql_file('./data/sql/misc/gdpr_northstar_removal.sql', data)


def remove_cio():
    # Removes CIO user data for GDPR compliance.
    data = {'customer_event': os.getenv('CIO_CUSTOMER_EVENT'),
            'email_bounced': os.getenv('CIO_EMAIL_BOUNCED'),
            'email_event': os.getenv('CIO_EMAIL_EVENT'),
            'email_sent': os.getenv('CIO_EMAIL_SENT'),
            'event_log': os.getenv('CIO_EVENT_LOG'),
            'users': os.getenv('NORTHSTAR_FT_SCHEMA')}
    run_sql_file('./data/sql/misc/gdpr_cio_removal.sql', data)


def main():
    remove_northstar()
    log("Northstar anonymization completed.")
    remove_cio()
    log("Customer.io anonymization completed.")
