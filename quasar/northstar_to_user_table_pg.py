from datetime import datetime as dt
import json
import psycopg2
import re
import sys
import time

from .config import config
from .northstarscraper import NorthstarScraper
from .utils import strip_str
from .database_pg import NorthstarDatabase

"""DS Northstar to Quasar User ETL script.

This ETL scripts scrapes the DoSomething Thor Northstar User API and ETL's the
output to our MySQL Quasar data warehouse.

The script takes an optional argument for what Northstar page result to start
on. This is mostly used to backfill from a certain page, or from the dawn
of time. Otherwise, pagination is stored in an small status tracking table
that gets updated on ingestion loop.

"""

class NorthstarDB:

    def __init__(self):
        db_opts = {}
        self.db = NorthstarDatabase(db_opts)


    def teardown(self):
        self.db.disconnect()


    def save_user(self, user):
        self.db.query_str(''.join(("INSERT INTO northstar.users (id, "
                                   "first_name, last_name, last_initial, "
                                   "photo, email, mobile, facebook_id, "
                                   "interests, birthdate, addr_street1, "
                                   "addr_street2, addr_city, addr_state, "
                                   "addr_zip, addr_source, source, "
                                   "source_detail, slack_id, sms_status, "
                                   "sms_paused, language, country, "
                                   "drupal_id, role, last_accessed_at, "
                                   "last_authenticated_at, "
                                   "last_messaged_at, "
                                   "updated_at, created_at) "
                                   "VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,"
                                   "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,"
                                   "%s,%s,%s,%s,%s,%s,%s,%s,%s) "
                                   "ON CONFLICT (id) DO UPDATE "
                                   "SET (id, first_name, last_name, "
                                   "last_initial, photo, email, mobile, "
                                   "facebook_id, interests, birthdate, "
                                   "addr_street1, addr_street2, "
                                   "addr_city, addr_state, addr_zip, "
                                   "addr_source, source, source_detail, "
                                   "slack_id, sms_status, sms_paused, "
                                   "language, country, drupal_id, "
                                   "role, last_accessed_at, "
                                   "last_authenticated_at, "
                                   "last_messaged_at, updated_at, "
                                   "created_at) = "
                                   "(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,"
                                   "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,"
                                   "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)")),
                          (user['id'], user['first_name'],
                           user['last_name'], user['last_initial'],
                           user['photo'], user['email'], user['mobile'],
                           user['facebook_id'], user['interests'],
                           user['birthdate'], user['addr_street1'],
                           user['addr_street2'], user['addr_city'],
                           user['addr_state'], user['addr_zip'],
                           user['addr_source'], user['source'],
                           user['source_detail'], user['slack_id'],
                           user['sms_status'], user['sms_paused'],
                           user['language'], user['country'],
                           user['drupal_id'], user['role'],
                           user['last_accessed_at'],
                           user['last_authenticated_at'],
                           user['last_messaged_at'],
                           user['updated_at'], user['created_at'],
                           user['id'], user['first_name'],
                           user['last_name'], user['last_initial'],
                           user['photo'], user['email'], user['mobile'],
                           user['facebook_id'], user['interests'],
                           user['birthdate'], user['addr_street1'],
                           user['addr_street2'], user['addr_city'],
                           user['addr_state'], user['addr_zip'],
                           user['addr_source'], user['source'],
                           user['source_detail'], user['slack_id'],
                           user['sms_status'], user['sms_paused'],
                           user['language'], user['country'],
                           user['drupal_id'], user['role'],
                           user['last_accessed_at'],
                           user['last_authenticated_at'],
                           user['last_messaged_at'],
                           user['updated_at'], user['created_at']),
                          user)


def _interval(hours_ago):
    def _format(hr):
        _time = int(time.time()) - (int(hr) * 3600)
        formatted = dt.fromtimestamp(_time).isoformat()
        return formatted

    start = _format(hours_ago)
    end = _format(hours_ago - 1)
    return (start, end)


def backfill_since():
    _backfill(sys.argv[1])


def _backfill(hours_ago=None):
    start_time = time.time()

    db = NorthstarDB()
    scraper = NorthstarScraper(config.ns_uri)
    save_progress = hours_ago is None

    def _process_page(page_n, page_response):
        res = page_response
        for user in res['data']:
            db.save_user(user)
        if save_progress:
            db.update_start_page(page_n)

    if hours_ago is not None:
        intervals = [_interval(hour) for hour in range(
            int(hours_ago) + 1) if hour > 0]

        for start, end in intervals:
            create_params = {'after[created_at]': str(
                start), 'before[created_at]': str(end)}
            update_params = {'after[updated_at]': str(
                start), 'before[updated_at]': str(end)}
            scraper.process_all_pages(
                '/v1/users', create_params, _process_page)
            scraper.process_all_pages(
                '/v1/users', update_params, _process_page)

    else:
        start_page = db.get_start_page()
        scraper.process_all_pages(
            '/v1/users', {'page': start_page}, _process_page)

    self.teardown()
    except_db.teardown()

    end_time = time.time()  # Record when script stopped running.
    duration = end_time - start_time  # Total duration in seconds.
    print('duration: ', duration)


if __name__ == "__main__":
    _backfill()
